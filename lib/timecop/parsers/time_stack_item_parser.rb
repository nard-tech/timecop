class Timecop
  class TimeStackItemParser
    def self.call(*args)
      new(*args).call
    end

    def initialize(*args)
      @args = args.dup
    end

    def call
      return first_arg if time?
      return time_klass.at(first_arg.to_time.to_f).getlocal if datetime?
      return local_time(first_arg.year, first_arg.month, first_arg.day) if date?
      return time_klass.now + first_arg if a_number?
      return time_klass.now if first_arg.nil?
      return time_klass.parse(first_arg) if parse?

      # we'll just assume it's a list of y/m/d/h/m/s
      year, month, day, hour, minute, second = @args
      local_time(year, month, day, hour, minute, second)
    end

    def time_klass
      Time.respond_to?(:zone) && Time.zone ? Time.zone : Time
    end

    private

    def first_arg
      @args.first
    end

    def time?
      first_arg.is_a?(Time)
    end

    def datetime?
      Object.const_defined?(:DateTime) && first_arg.is_a?(DateTime)
    end

    def date?
      Object.const_defined?(:Date) && first_arg.is_a?(Date)
    end

    def a_number?
      @args.length == 1 && (first_arg.is_a?(Integer) || first_arg.is_a?(Float))
    end

    def parse?
      first_arg.is_a?(String) && Time.respond_to?(:parse)
    end

    def local_time(year = 2000, month = 1, day = 1, hour = 0, minute = 0, second = 0)
      time_klass.local(year, month, day, hour, minute, second)
    end
  end
end
