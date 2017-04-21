require 'active_support/concern'
require 'active_record/errors'
require 'active_record/callbacks'

module BeReadonly
  module Model
    extend ActiveSupport::Concern

    module ClassMethods
      def be_readonly
        # intentionally not in ClassMethods which is automatically extended
        # via ActiveSupport::Concern
        extend BeReadonlyClassMethods

        # intentionally not just InstanceMethods as those would be automatically
        # included via ActiveSupport::Concern
        include BeReadonlyInstanceMethods

        before_destroy :enforce_readonly_on_instance_methods!
      end
    end

    module BeReadonlyClassMethods
      def delete(id_or_array)
        enforce_readonly_on_class_methods!
        super
      end

      def delete_all(conditions = nil)
        enforce_readonly_on_class_methods!
        super
      end

      def update_all(conditions = nil)
        enforce_readonly_on_class_methods!
        super
      end

      private
      def enforce_readonly_on_class_methods!
        return unless BeReadonly.enabled
        return unless BeReadonly.any_callers_blacklisted?

        fail ActiveRecord::ReadOnlyRecord
      end
    end

    module BeReadonlyInstanceMethods
      def readonly?
        return true if enforce_be_readonly?
        super
      end

      def delete
        enforce_readonly_on_instance_methods!
        super
      end

      private
      def enforce_readonly_on_instance_methods!
        return unless enforce_be_readonly?

        fail ActiveRecord::ReadOnlyRecord
      end

      def enforce_be_readonly?
        return false unless BeReadonly.enabled
        return false if BeReadonly.create_allowed && new_record?
        BeReadonly.any_callers_blacklisted?
      end
    end
  end
end
