module WorkspaceUI
  class HomeController < BaseController
    def index
      redirect_to workspace_invoices_path(month: Time.zone.now.strftime('%Y-%m')) if current_company.invoices.count > 0
    end
  end
end