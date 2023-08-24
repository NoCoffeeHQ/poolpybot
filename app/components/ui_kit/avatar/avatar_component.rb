# frozen_string_literal: true

class UIKit::Avatar::AvatarComponent < ViewComponent::Base
  attr_reader :attachment, :name, :email

  def initialize(attachment:, name:, email:)
    super
    @attachment = attachment
    @name = name
    @email = email
  end
end
