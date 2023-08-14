# frozen_string_literal: true

module WorkspaceUI
  class HomeController < BaseController
    def index
      return unless current_user.invoices.count.positive? && params[:no_redirection].blank?

      redirect_to current_invoices_path
    end
  end
end
