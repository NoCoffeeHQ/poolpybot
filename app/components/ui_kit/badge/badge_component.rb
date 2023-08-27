# frozen_string_literal: true

module UIKit
  module Badge
    class BadgeComponent < ViewComponent::Base
      attr_reader :label, :type

      def initialize(label: nil, type: nil)
        super
        @label = label
        @type = type&.to_sym || :notice
      end

      def color_class_names
        case type
        when :success then 'bg-green-50 text-green-700 ring-green-600/20'
        when :error then 'bg-red-50 text-red-700 ring-red-600/20'
        else
          'bg-yellow-50 text-yellow-700 ring-yellow-600/20'
        end
      end
    end
  end
end
