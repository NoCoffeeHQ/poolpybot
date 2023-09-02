# frozen_string_literal: true

module WorkspaceUI
  class InvoiceSuppliersController < BaseController
    def index
      @suppliers = resources.includes(:sorted_invoices).ordered
    end

    def edit
      @supplier = resources.find(params[:id])
    end

    def update
      @supplier = resources.find(params[:id])
      if @supplier.update(invoice_supplier_params)
        redirect_to workspace_invoice_suppliers_path, notice: t('.flash.success')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      resources.find(params[:id]).destroy
      redirect_to workspace_invoice_suppliers_path, notice: t('.flash.success')
    end

    protected

    def resources
      current_company.invoice_suppliers
    end

    def invoice_supplier_params
      params.require(:invoice_supplier).permit(:display_name).tap do |safe_params|
        safe_params[:display_name] = nil if safe_params[:display_name].blank?
      end
    end
  end
end