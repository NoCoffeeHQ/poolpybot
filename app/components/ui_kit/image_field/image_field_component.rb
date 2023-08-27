# frozen_string_literal: true

module UIKit
  module ImageField
    class ImageFieldComponent < ViewComponent::Base
      renders_one :label

      attr_reader :form, :attribute, :max_size, :direct_upload

      def initialize(form:, attribute:, max_size: 1.megabytes, direct_upload: false)
        super
        @form = form
        @attribute = attribute
        @max_size = max_size
        @direct_upload = direct_upload
      end

      delegate :attached?, to: :attachment

      def attached_and_persisted?
        attachment.attached? && attachment.persisted?
      end

      def attachment
        form.object.send(attribute)
      end
    end
  end
end
