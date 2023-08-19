# frozen_string_literal: true

module UIKit
  module Alert
    class AlertComponent < ViewComponent::Base
      attr_reader :flash

      def initialize(flash:)
        super
        @flash = flash
      end

      def render?
        !flash.empty?
      end
    end
  end
end
