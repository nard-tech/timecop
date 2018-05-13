class Timecop
  # A data class for carrying around "time movement" objects.  Makes it easy to keep track of the time
  # movements on a simple stack.
  class TimeStackItem #:nodoc:
    MOCK_TYPES = %i[freeze travel scale].freeze

    def initialize(mock_type, *args)
      raise "Unknown mock_type #{mock_type}" unless MOCK_TYPES.include?(mock_type)
      @travel_offset  = @scaling_factor = nil
      @scaling_factor = args.shift if mock_type == :scale
      @mock_type      = mock_type
      @time           = parse_time(*args)
      @time_was       = Time.now_without_mock_time
      @travel_offset  = compute_travel_offset
    end

    attr_reader :scaling_factor
    attr_reader :mock_type

    def year
      time.year
    end

    def month
      time.month
    end

    def day
      time.day
    end

    def hour
      time.hour
    end

    def min
      time.min
    end

    def sec
      time.sec
    end

    def utc_offset
      time.utc_offset
    end

    def travel_offset
      @travel_offset unless mock_type == :freeze
    end

    def travel_offset_days
      (@travel_offset / 60 / 60 / 24).round
    end

    def time(time_klass = Time) #:nodoc:
      time = if @time.respond_to?(:in_time_zone)
               time_klass.at(@time.dup.localtime)
             else
               time_klass.at(@time)
             end

      if travel_offset.nil?
        time
      elsif scaling_factor.nil?
        time_klass.at(Time.now_without_mock_time + travel_offset)
      else
        time_klass.at(scaled_time)
      end
    end

    def scaled_time
      (@time + (Time.now_without_mock_time - @time_was) * scaling_factor).to_f
    end

    def date(date_klass = Date)
      date_klass.jd(time.__send__(:to_date).jd)
    end

    def datetime(datetime_klass = DateTime)
      datetime_klass.new(year, month, day, hour, min, sec_normalized, utc_offset_to_rational(utc_offset))
    end

    private

    def sec_normalized
      if Float.method_defined?(:to_r)
        sec + time.to_f % 1
      else
        sec
      end
    end

    def utc_offset_to_rational(utc_offset)
      Rational(utc_offset, 24 * 60 * 60)
    end

    def parse_time(*args)
      args = args.dup
      arg = args.shift

      if arg.is_a?(Time)
        arg
      elsif Object.const_defined?(:DateTime) && arg.is_a?(DateTime)
        time_klass.at(arg.to_time.to_f).getlocal
      elsif Object.const_defined?(:Date) && arg.is_a?(Date)
        time_klass.local(arg.year, arg.month, arg.day, 0, 0, 0)
      elsif args.empty? && (arg.is_a?(Integer) || arg.is_a?(Float))
        time_klass.now + arg
      elsif arg.nil?
        time_klass.now
      elsif arg.is_a?(String) && Time.respond_to?(:parse)
        time_klass.parse(arg)
      else
        # we'll just assume it's a list of y/m/d/h/m/s
        year = arg
        month, day, hour, minute, second = args

        year   ||= 2000
        month  ||= 1
        day    ||= 1
        hour   ||= 0
        minute ||= 0
        second ||= 0
        time_klass.local(year, month, day, hour, minute, second)
      end
    end

    def compute_travel_offset
      time - Time.now_without_mock_time
    end

    def times_are_equal_within_epsilon(t1, t2, epsilon_in_seconds)
      (t1 - t2).abs < epsilon_in_seconds
    end

    def time_klass
      Time.respond_to?(:zone) && Time.zone ? Time.zone : Time
    end
  end
end
