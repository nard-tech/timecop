class Timecop
  class DateParser
    def self.object_class
      ::Date
    end

    def self.call(parsed_date, mocked_time_stack_item, *args)
      new(parsed_date, mocked_time_stack_item, *args).call
    end

    def initialize(parsed_date, mocked_time_stack_item, *args)
      @parsed_date = parsed_date
      @mocked_time_stack_item = mocked_time_stack_item
      @date_hash = self.class.object_class._parse(*args)
    end

    def call
      return parsed_date if year && mon
      return self.class.object_class.new(mocked_time_stack_item.year, mon, mday) if mon && mday
      return closest_wday(Date.today, wday) if wday
      parsed_date + mocked_time_stack_item.travel_offset_days
    end

    private

    attr_reader :parsed_date, :mocked_time_stack_item, :date_hash

    def year
      date_hash[:year]
    end

    def mon
      date_hash[:mon]
    end

    def mday
      date_hash[:mday]
    end

    def wday
      date_hash[:wday]
    end

    def closest_wday(today, wday)
      result = today - today.wday
      result += 1 until wday == result.wday
      result
    end
  end
end
