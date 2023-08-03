# frozen_string_literal: true

class UIKit::PrimaryButton::PrimaryButtonComponent < ViewComponent::Base
  attr_reader :type, :label

  def initialize(type:, label:, full_width: false)
    @type = type
    @label = label
    @full_width = full_width
  end

  def full_width?
    !!@full_width
  end
end
