# frozen_string_literal: true

class UIKit::FormInput::FormInputComponent < ViewComponent::Base
  renders_one :label
  renders_one :label_hint 

  attr_reader :form, :attribute, :locale, :html_data

  def initialize(form:, attribute:, locale: nil, html_data: nil)
    @form = form
    @attribute = attribute
    @locale = locale
    @html_data = html_data || {}
  end

  def locale_label
    I18n.t(locale, scope: 'locales')
  end

  def translated_attribute
    locale ? :"#{attribute}_#{locale.downcase.gsub('-', '_')}" : attribute
  end

  def form_for
    form.field_id(translated_attribute, index: nil)
  end

  def errors
    form.object.errors[attribute].join(', ')
  end

  def placeholder
    I18n.t(attribute, scope: ['forms', object_name, 'placeholders'], locale_label: locale_label, default: nil)
  end

  def hint    
    I18n.t(attribute, scope: ['forms', object_name, 'hints'], locale_label: locale_label, default: nil)
  end

  def hint?
    hint.present?
  end

  def placeholder?
    placeholder.present?
  end

  def object_name
    form.object.model_name.singular
  end
end
