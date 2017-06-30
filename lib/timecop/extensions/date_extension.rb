require 'date'

class Date #:nodoc:
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
      return parsed_date unless mocked_time_stack_item

      date_hash = Date._parse(*args)

      if date_hash[:year] && date_hash[:mon]
        parsed_date
      elsif date_hash[:mon] && date_hash[:mday]
        Date.new(mocked_time_stack_item.year, date_hash[:mon], date_hash[:mday])
      elsif date_hash[:wday]
        closest_wday(date_hash[:wday])
      else
        parsed_date + mocked_time_stack_item.travel_offset_days
      end
    end

    alias_method :parse, :parse_with_mock_date

    # @!endgroup

    def mocked_time_stack_item
      Timecop.top_stack_item
    end

    def closest_wday(wday)
      today = Date.today
      result = today - today.wday
      result += 1 until wday == result.wday
      result
    end
  end
end
