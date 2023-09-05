# frozen_string_literal: true

module WorkspaceUI
  class HomeController < BaseController
    def index
      has_invoices = current_user.invoices.count.positive?
      path = has_invoices ? current_invoices_path : workspace_instructions_path
      redirect_to path
    end
  end
end
