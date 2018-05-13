require 'time'

class Time #:nodoc:
  include Timecop::Extension::Mock
  include Timecop::Extension::Now

  class << self
    def mock_time
      mocked_time_stack_item.nil? ? nil : mocked_time_stack_item.time(self)
    end

    # @!group now

    alias now_without_mock_time now

    alias now now_with_mock_time

    # @!group new

    alias new_without_mock_time new

    def new_with_mock_time(*args)
      args.size <= 0 ? now : new_without_mock_time(*args)
    end

    alias new new_with_mock_time

    # @!endgroup
  end
end
