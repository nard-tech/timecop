class Timecop
  module Extension
    module Now
      extend ActiveSupport::Concern

      module ClassMethods
        def now_with_mock_time
          mock_time || now_without_mock_time
        end

        def now_without_mock_time
          raise NotImplementedError
        end

        def mock_time
          raise NotImplementedError
        end
      end
    end
  end
end
