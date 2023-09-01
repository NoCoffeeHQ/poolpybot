class AddInvoicesCountToInvoiceSuppliers < ActiveRecord::Migration[7.0]
  def change
    add_column :invoice_suppliers, :invoices_count, :integer
  end
end
