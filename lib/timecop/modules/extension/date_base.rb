class Timecop
  module Extension
    module DateBase
      extend ActiveSupport::Concern

      module ClassMethods
        def parse_with_mock_date(*args)
          parsed_date = parse_without_mock_date(*args)
          if mocked_time_stack_item
            parser_class.call(parsed_date, mocked_time_stack_item, *args)
          else
            parsed_date
          end
        end

        private

        def parser_class
          raise NotImplementedError
        end
      end
    end
  end
end
