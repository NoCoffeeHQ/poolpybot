module WorkspaceUI
  class HomeController < BaseController

    def index
      if current_user.invoices.count > 0 && params[:no_redirection].blank?
        redirect_to current_invoices_path 
      end
    end
  end
end