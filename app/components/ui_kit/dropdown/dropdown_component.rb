# frozen_string_literal: true

module UIKit
  module Dropdown
    class DropdownComponent < ViewComponent::Base
      renders_one :label

      # rubocop:disable Lint/MissingSuper
      def initialize(label_class: '', content_class: '', orientation: :left, arrow: true)
        @label_class = label_class
        @content_class = content_class
        @orientation = orientation
        @arrow = arrow
      end
      # rubocop:enable Lint/MissingSuper

      def arrow?
        @arrow
      end
    end
  end
end
