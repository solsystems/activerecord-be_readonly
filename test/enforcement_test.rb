require 'test/unit'
require './lib/activerecord-be_readonly'

class EnforcementTest < Test::Unit::TestCase
  class MockActiveRecord
    class << self
      def before_destroy(method_name)
        @@callbacks ||= []
        @@callbacks << method_name
      end

      def delete(id_or_array); true; end
      def delete_all(conditions = nil); true; end
      def update_all(conditions = nil); true; end
    end

    def initialize(args = {})
      @new_record = args[:new_record]
    end

    def new_record?; @new_record; end
    def readonly?; false; end
    def delete; true; end

    def destroy
      @@callbacks.each { |m| send(m) }
      true
    end
  end

  class TestObject < MockActiveRecord
    include BeReadonly::Now
  end

  def setup
    BeReadonly.reset
  end

  def test_when_enabled_globally
    BeReadonly.enable

    assert_raise(ActiveRecord::ReadOnlyRecord) { TestObject.delete_all }
    assert_raise(ActiveRecord::ReadOnlyRecord) { TestObject.delete(1) }
    assert_raise(ActiveRecord::ReadOnlyRecord) { TestObject.update_all }

    subject = TestObject.new(:new_record => true)
    assert_equal(true, subject.readonly?)
    assert_raise(ActiveRecord::ReadOnlyRecord) { subject.destroy }
    assert_raise(ActiveRecord::ReadOnlyRecord) { subject.delete }

    subject = TestObject.new(:new_record => false)
    assert_equal(true, subject.readonly?)
    assert_raise(ActiveRecord::ReadOnlyRecord) { subject.destroy }
    assert_raise(ActiveRecord::ReadOnlyRecord) { subject.delete }
  end

  def test_when_create_allowed
    BeReadonly.allow_create

    assert_raise(ActiveRecord::ReadOnlyRecord) { TestObject.delete_all }
    assert_raise(ActiveRecord::ReadOnlyRecord) { TestObject.delete(1) }
    assert_raise(ActiveRecord::ReadOnlyRecord) { TestObject.update_all }

    subject = TestObject.new(:new_record => true)
    assert_equal(false, subject.readonly?)
    assert_nothing_raised { subject.destroy }
    assert_nothing_raised { subject.delete }

    subject = TestObject.new(:new_record => false)
    assert_equal(true, subject.readonly?)
    assert_raise(ActiveRecord::ReadOnlyRecord) { subject.destroy }
    assert_raise(ActiveRecord::ReadOnlyRecord) { subject.delete }
  end

  def test_when_enforced_for_blacklist_with_match
    BeReadonly.enable_for_blacklist(/#{__FILE__}/)

    assert_raise(ActiveRecord::ReadOnlyRecord) { TestObject.delete_all }
    assert_raise(ActiveRecord::ReadOnlyRecord) { TestObject.delete(1) }
    assert_raise(ActiveRecord::ReadOnlyRecord) { TestObject.update_all }

    subject = TestObject.new(:new_record => true)
    assert_equal(true, subject.readonly?)
    assert_raise(ActiveRecord::ReadOnlyRecord) { subject.destroy }
    assert_raise(ActiveRecord::ReadOnlyRecord) { subject.delete }

    subject = TestObject.new(:new_record => false)
    assert_equal(true, subject.readonly?)
    assert_raise(ActiveRecord::ReadOnlyRecord) { subject.destroy }
    assert_raise(ActiveRecord::ReadOnlyRecord) { subject.delete }
  end

  def test_when_enforced_for_blacklist_no_match
    BeReadonly.enable_for_blacklist(/abc/)

    assert_nothing_raised { TestObject.delete_all }
    assert_nothing_raised { TestObject.delete(1) }
    assert_nothing_raised { TestObject.update_all }

    subject = TestObject.new(:new_record => true)
    assert_equal(false, subject.readonly?)
    assert_nothing_raised { subject.destroy }
    assert_nothing_raised { subject.delete }

    subject = TestObject.new(:new_record => false)
    assert_equal(false, subject.readonly?)
    assert_nothing_raised { subject.destroy }
    assert_nothing_raised { subject.delete }
  end
end
