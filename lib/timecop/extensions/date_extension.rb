require 'date'
require File.join(File.dirname(__FILE__), '..', 'parsers', 'date_parser')

class Date #:nodoc:
  include Timecop::Extension::Mock
  include Timecop::Extension::DateBase

  class << self
    def mock_date
      mocked_time_stack_item.nil? ? nil : mocked_time_stack_item.date(self)
    end

    # @!group today

    alias_method :today_without_mock_date, :today

    def today_with_mock_date
      mock_date || today_without_mock_date
    end

    alias_method :today, :today_with_mock_date

    # @!group strptime

    alias_method :strptime_without_mock_date, :strptime

    def strptime_with_mock_date(str = '-4712-01-01', fmt = '%F', start = Date::ITALY)
      unless start == Date::ITALY
        raise ArgumentError, "Timecop's #{self}::#{__method__} only " \
          'supports Date::ITALY for the start argument.'
      end

      Time.strptime(str, fmt).to_date
    end

    alias_method :strptime, :strptime_with_mock_date

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
      Timecop::DateParser
    end
  end
end
