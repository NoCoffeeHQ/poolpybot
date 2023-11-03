# frozen_string_literal: true

module Authentication
  class BaseController < ApplicationController
    layout 'authentication'

    before_action :set_locale

    private

    def set_locale
      locale = begin
        request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
      rescue StandardError
        nil
      end
      locale = I18n.default_locale unless I18n.available_locales.map(&:to_s).include?(locale)
      I18n.locale = locale
    end
  end
end
