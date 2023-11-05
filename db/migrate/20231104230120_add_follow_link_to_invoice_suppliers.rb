class AddFollowLinkToInvoiceSuppliers < ActiveRecord::Migration[7.1]
  def change
    add_column :invoice_suppliers, :follow_link, :boolean, default: false
  end
end
