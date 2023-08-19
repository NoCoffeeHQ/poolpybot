# frozen_string_literal: true

module WorkspaceUI
  class InvoicesController < BaseController
    def index
      @invoices = current_company.invoices
      .includes(:invoice_supplier)
      .with_attached_pdf_document
      .search(
        **params.permit(:month, :status, :supplier_id).to_h.symbolize_keys
      )
    end

    def bulk_create
      params[:pdf_documents].each do |pdf_signed_id|
        services.pdf_invoice_creator.call_later(
          user_id: current_user.id,
          pdf_signed_id: pdf_signed_id
        )
      end

      flash[:notice] = t('.notice', count: params[:pdf_documents].count)

      # TODO: keep the month from the previous url
      redirect_to workspace_invoices_path
    end
  end
end
