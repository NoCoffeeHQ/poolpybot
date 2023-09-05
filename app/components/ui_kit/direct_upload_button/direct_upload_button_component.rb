# frozen_string_literal: true

module UIKit
  module DirectUploadButton
    class DirectUploadButtonComponent < ViewComponent::Base
      attr_reader :label, :url, :accept, :multiple, :size

      def initialize(label:, url:, accept: nil, size: :md, multiple: false)
        super
        @label = label
        @url = url
        @accept = accept
        @multiple = multiple
        @size = size
      end

      def uploading_label
        t('.uploading_label')
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
