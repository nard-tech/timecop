require 'active_support/concern'

class Timecop
  module Extension
    module Mock
      extend ActiveSupport::Concern

      module ClassMethods
        def mocked_time_stack_item
          Timecop.top_stack_item
        end
      end
    end
  end
end
