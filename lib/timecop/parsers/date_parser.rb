require File.join(File.dirname(__FILE__), 'date_base_parser')

class Timecop
  class DateParser < DateBaseParser
    def self.object_class
      ::Date
    end
  end
end
