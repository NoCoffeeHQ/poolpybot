# frozen_string_literal: true

class UIKit::TextField::TextFieldComponent < UIKit::FormInput::FormInputComponent
  attr_reader :form, :attribute, :locale, :max_length

  def initialize(form:, attribute:, locale: nil)
    @form = form
    @attribute = attribute
    @locale = locale
  end
end
