require 'date'
require File.join(File.dirname(__FILE__), '..', 'parsers', 'date_time_parser')

class DateTime #:nodoc:
  include Timecop::Extension::Mock
  include Timecop::Extension::Now
  include Timecop::Extension::DateBase

  class << self
    def mock_time
      mocked_time_stack_item.nil? ? nil : mocked_time_stack_item.datetime(self)
    end

    # @!group now

    alias_method :now_without_mock_time, :now

    alias_method :now, :now_with_mock_time

    # @!group parse

    alias_method :parse_without_mock_date, :parse

    def parse_with_mock_date(*args)
      parsed_date = parse_without_mock_date(*args)
      if mocked_time_stack_item
        parser_class.call(parsed_date, mocked_time_stack_item, *args)
      else
        parsed_date
      end
    end

    alias_method :parse, :parse_with_mock_date

    # @!endgroup

    private

    def parser_class
      Timecop::DateTimeParser
    end
  end
end
