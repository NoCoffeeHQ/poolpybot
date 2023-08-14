# frozen_string_literal: true

module AppKit
  module Logo
    class LogoComponent < ViewComponent::Base
      attr_reader :size

      def initialize(url: nil, size: :md)
        super
        @url = url
        @size = size
      end

      def url
        @url || helpers.root_path
      end

      def classes
        {
          md: { img: 'h-8', title: 'text-sm', sub_title: 'text-xs' },
          lg: { img: 'h-12', title: 'text-md', sub_title: 'text-sm' }
        }[size]
      end
    end
  end
end
