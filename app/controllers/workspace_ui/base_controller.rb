module WorkspaceUI
  class BaseController < ApplicationController
    layout 'workspace_ui'

    before_action :require_login

    helper_method :current_invoices_path

    private

    def current_invoices_path
      workspace_invoices_path(month: Time.zone.now.strftime('%Y-%m'))
    end

    def current_company
      current_user&.company
    end
  end
end