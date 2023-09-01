# frozen_string_literal: true

class UIKit::RadioButtons::RadioButtonsComponent < UIKit::FormInput::FormInputComponent
  attr_reader :choices

  def initialize(form:, attribute:, choices:)
    super(form: form, attribute: attribute)
    @choices = choices
  end
end
