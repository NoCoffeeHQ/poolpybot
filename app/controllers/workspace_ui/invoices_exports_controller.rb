# frozen_string_literal: true

module WorkspaceUI
  class InvoicesExportsController < BaseController

    def create
      date = Date.parse("#{search_params[:month]}-01")
      services.email_invoices_exporter.call_later(user_id: current_user.id, date: date)

      redirect_to workspace_invoices_path(search_params), notice: t('.flash.success')
    end

    private

    def search_params
      params.permit(:month, :status, :supplier_id)
    end

  end
end