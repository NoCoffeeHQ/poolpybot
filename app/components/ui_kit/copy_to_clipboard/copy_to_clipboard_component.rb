# frozen_string_literal: true

module UIKit
  module CopyToClipboard
    class CopyToClipboardComponent < ViewComponent::Base
      attr_reader :value

      def initialize(value:)
        super
        @value = value
      end
    end
  end
end
