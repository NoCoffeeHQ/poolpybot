module WorkspaceUI
  class InvoicesController < BaseController
    def index
      @invoices = current_company.invoices.foo_filter(
        **(params.permit(:month, :status, :supplier_id).to_h.symbolize_keys)
      )
    end

    def create
      raise 'TODO'
    end
  end
end