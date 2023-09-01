# frozen_string_literal: true

module WorkspaceUI
  class BaseController < ApplicationController
    layout 'workspace_ui'

    before_action :require_login

    before_action :set_locale

    helper_method :current_invoices_path

    private

    def current_invoices_path
      workspace_invoices_path(month: Time.zone.now.strftime('%Y-%m'))
    end

    def current_company
      current_user&.company
    end

    def set_locale
      I18n.locale = current_user.locale || I18n.default_locale
    end
  end
end
