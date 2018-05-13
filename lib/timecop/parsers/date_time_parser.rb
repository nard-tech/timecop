require File.join(File.dirname(__FILE__), 'date_base_parser')

class Timecop
  class DateTimeParser < DateBaseParser
    def self.object_class
      ::DateTime
    end

    def closest_wday(today, wday)
      super(today, wday).to_datetime
    end
  end
end
