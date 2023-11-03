# frozen_string_literal: true

module UIKit
  module PrimaryButton
    class PrimaryButtonComponent < ViewComponent::Base
      attr_reader :type, :label, :url

      def initialize(type:, label: nil, url: nil, full_width: false, disabled: false)
        super
        @type = type
        @label = label
        @full_width = full_width
        @disabled = disabled
        @url = url
      end

      def full_width?
        !!@full_width
      end

      def disabled?
        !!@disabled
      end
    end
  end
end
