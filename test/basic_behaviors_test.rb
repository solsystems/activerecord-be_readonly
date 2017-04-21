require 'test/unit'
require './lib/activerecord-be_readonly'

class BasicBehaviorsTest < Test::Unit::TestCase
  def test_enable
    BeReadonly.enabled = false
    BeReadonly.enable
    assert_equal(true, BeReadonly.enabled)
  end

  def test_disable
    BeReadonly.enabled = true
    BeReadonly.disable
    assert_equal(false, BeReadonly.enabled)
  end

  def test_allow_create
    BeReadonly.enabled        = false
    BeReadonly.create_allowed = false

    BeReadonly.allow_create
    assert_equal(true, BeReadonly.create_allowed)
    assert_equal(true, BeReadonly.enabled)
  end

  def test_disallow_create
    BeReadonly.enabled        = true
    BeReadonly.create_allowed = true

    BeReadonly.disallow_create
    assert_equal(false, BeReadonly.create_allowed)
    assert_equal(true, BeReadonly.enabled)
  end

  def test_enable_for_blacklist
    BeReadonly.enabled        = false
    BeReadonly.create_allowed = false

    BeReadonly.enable_for_blacklist(/abc/)
    assert_equal(/abc/, BeReadonly.caller_blacklist_regex)
    assert_equal(true, BeReadonly.enabled)
  end

  def test_any_callers_blacklisted_no_blacklist
    BeReadonly.enable
    assert_equal(nil, BeReadonly.caller_blacklist_regex)
    assert_equal(true, BeReadonly.any_callers_blacklisted?)
  end

  def test_any_callers_blacklisted_with_match
    BeReadonly.enable_for_blacklist(/#{__FILE__}/)
    assert_equal(true, BeReadonly.any_callers_blacklisted?)
  end

  def test_any_callers_blacklisted_no_match
    BeReadonly.enable_for_blacklist(/abc/)
    assert_equal(false, BeReadonly.any_callers_blacklisted?)
  end
end
