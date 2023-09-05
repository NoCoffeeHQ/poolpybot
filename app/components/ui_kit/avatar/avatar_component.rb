# frozen_string_literal: true

module UIKit
  module Avatar
    class AvatarComponent < ViewComponent::Base
      attr_reader :attachment, :name, :email

      def initialize(attachment:, name: nil, email: nil)
        super
        @attachment = attachment
        @name = name
        @email = email
      end
    end
  end
end
