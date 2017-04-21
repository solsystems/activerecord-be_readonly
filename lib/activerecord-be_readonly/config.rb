module BeReadonly
  class << self
    attr_accessor :enabled
    attr_accessor :create_allowed
    attr_accessor :caller_blacklist_regex

    def enable
      self.enabled = true
    end

    def disable
      self.enabled = false
    end

    def allow_create
      self.enabled        = true
      self.create_allowed = true
    end

    def disallow_create
      self.create_allowed = false
    end

    def enable_for_blacklist(regex)
      self.enabled                = true
      self.caller_blacklist_regex = regex
    end

    def any_callers_blacklisted?
      return true if caller_blacklist_regex.nil?

      caller.any? do |c|
        c =~ BeReadonly.caller_blacklist_regex
      end
    end

    def reset
      self.enabled                = false
      self.create_allowed         = false
      self.caller_blacklist_regex = nil
    end
  end
end
