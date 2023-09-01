# frozen_string_literal: true

module UIKit
  module RadioButtons
    class RadioButtonsComponent < UIKit::FormInput::FormInputComponent
      attr_reader :choices

      def initialize(form:, attribute:, choices:)
        super(form: form, attribute: attribute)
        @choices = choices
      end
    end
  end
end
