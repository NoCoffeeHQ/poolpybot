# frozen_string_literal: true

class UIKit::Notification::NotificationComponent < ViewComponent::Base
  attr_reader :flash

  def initialize(flash:)
    @flash = flash
  end

  def render?
    !flash.empty?
  end
end
