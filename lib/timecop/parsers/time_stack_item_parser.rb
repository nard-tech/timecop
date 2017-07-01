class Timecop
  class TimeStackItemParser
    def self.call(*args)
      new(*args).call
    end

    def initialize(*args)
      @args = args.dup
    end

    def call
      first_arg = @args.first
      if first_arg.is_a?(Time)
        first_arg
      elsif Object.const_defined?(:DateTime) && first_arg.is_a?(DateTime)
        time_klass.at(first_arg.to_time.to_f).getlocal
      elsif Object.const_defined?(:Date) && first_arg.is_a?(Date)
        time_klass.local(first_arg.year, first_arg.month, first_arg.day, 0, 0, 0)
      elsif @args.length == 1 && (first_arg.is_a?(Integer) || first_arg.is_a?(Float))
        time_klass.now + first_arg
      elsif first_arg.nil?
        time_klass.now
      elsif first_arg.is_a?(String) && Time.respond_to?(:parse)
        time_klass.parse(first_arg)
      else
        # we'll just assume it's a list of y/m/d/h/m/s
        year, month, day, hour, minute, second = @args
        year   ||= 2000
        month  ||= 1
        day    ||= 1
        hour   ||= 0
        minute ||= 0
        second ||= 0
        time_klass.local(year, month, day, hour, minute, second)
      end
    end

    def time_klass
      Time.respond_to?(:zone) && Time.zone ? Time.zone : Time
    end
  end
end
