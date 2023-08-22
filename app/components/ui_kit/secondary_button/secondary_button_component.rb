# frozen_string_literal: true

# frozen_string_literal: true

module UIKit
  module SecondaryButton
    class SecondaryButtonComponent < ViewComponent::Base
      attr_reader :label, :url, :action, :size

      def initialize(label:, url: '#', action: nil, size: :md)
        @label = label
        @url = url
        @action = action
        @size = size
      end

      def size_classes
        case size
        when :xs then 'py-1 px-2 text-xs'
        when :sm then 'py-1 px-2 text-sm'
        else 'py-2 px-3 text-sm'
        end
      end

    end
  end
end