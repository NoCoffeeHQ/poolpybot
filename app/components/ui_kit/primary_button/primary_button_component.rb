# frozen_string_literal: true

module UIKit
  module PrimaryButton
    class PrimaryButtonComponent < ViewComponent::Base
      attr_reader :type, :label

      def initialize(type:, label: nil, full_width: false)
        super
        @type = type
        @label = label
        @full_width = full_width
      end

      def full_width?
        !!@full_width
      end
    end
  end
end
