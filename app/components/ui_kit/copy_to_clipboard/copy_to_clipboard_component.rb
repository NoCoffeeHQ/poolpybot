# frozen_string_literal: true

class UIKit::CopyToClipboard::CopyToClipboardComponent < ViewComponent::Base
  attr_reader :value

  def initialize(value:)
    super
    @value = value
  end
end
