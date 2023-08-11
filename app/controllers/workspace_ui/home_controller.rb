module WorkspaceUI
  class HomeController < BaseController
    def index
      redirect_to current_invoices_path if current_user.invoices.count > 0
    end
  end
end