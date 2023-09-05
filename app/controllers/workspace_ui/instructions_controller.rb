# frozen_string_literal: true

module WorkspaceUI
  class InstructionsController < BaseController
    def index
      @has_invoices = current_user.invoices.count.positive?
      if @has_invoices
        @invoice_emails = InvoiceEmail
          .select('distinct ON (invoice_supplier_id) *')
          .joins(invoice: [:invoice_supplier])
          .where(Invoice[:user_id].eq(current_user.id))
          .order(Invoice[:invoice_supplier_id])
      end
    end
  end
end
