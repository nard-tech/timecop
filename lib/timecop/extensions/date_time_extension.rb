require 'date'

class DateTime #:nodoc:
  include Timecop::Extension::Mock

  class << self
    def mock_time
      mocked_time_stack_item.nil? ? nil : mocked_time_stack_item.datetime(self)
    end

    # @!group now

    alias_method :now_without_mock_time, :now

    def now_with_mock_time
      mock_time || now_without_mock_time
    end

    alias_method :now, :now_with_mock_time

    # @!group parse

    alias_method :parse_without_mock_date, :parse

    def parse_with_mock_date(*args)
      parsed_date = parse_without_mock_date(*args)
      return parsed_date unless mocked_time_stack_item

      date_hash = DateTime._parse(*args)

      if date_hash[:year] && date_hash[:mon]
        parsed_date
      elsif date_hash[:mon] && date_hash[:mday]
        DateTime.new(mocked_time_stack_item.year, date_hash[:mon], date_hash[:mday])
      elsif date_hash[:wday]
        Date.closest_wday(date_hash[:wday]).to_datetime
      else
        parsed_date + mocked_time_stack_item.travel_offset_days
      end
    end

    alias_method :parse, :parse_with_mock_date

    # @!endgroup
  end
end
