# frozen_string_literal: true

module WorkspaceUI
  class FailedInvoicesController < BaseController
    def show
      @invoice = current_company.invoices.failed.find(params[:id])
      render layout: false
    end
  end
end
