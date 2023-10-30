# frozen_string_literal: true

module Authentication
  class BaseController < ApplicationController
    layout 'authentication'

    before_action :set_locale

    private

    def set_locale
      locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first rescue nil
      locale = I18n.default_locale unless I18n.available_locales.map(&:to_s).include?(locale)
      I18n.locale = locale
    end
  end
end
