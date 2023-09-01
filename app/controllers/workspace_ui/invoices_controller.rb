# frozen_string_literal: true

module WorkspaceUI
  class InvoicesController < BaseController
    helper_method :search_params

    def index
      @invoices = current_company.invoices.optimized
                                 .search(
                                   **search_params.to_h.symbolize_keys
                                 )
    end

    def bulk_create
      params[:files].each do |pdf_signed_id|
        services.pdf_invoice_creator.call_later(
          user_id: current_user.id,
          pdf_signed_id: pdf_signed_id
        )
      end

      flash[:notice] = t('.flash.success', count: params[:files].count)

      redirect_to workspace_invoices_path
    end

    def destroy
      current_company.invoices.find(params[:id]).destroy
      redirect_to workspace_invoices_path(search_params), notice: t('.flash.success')
    end

    private

    def search_params
      params.permit(:month, :status, :supplier_id)
    end
  end
end
