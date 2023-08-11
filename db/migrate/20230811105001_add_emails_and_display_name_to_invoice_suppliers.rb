class AddEmailsAndDisplayNameToInvoiceSuppliers < ActiveRecord::Migration[7.0] 
  disable_ddl_transaction!
  def change
    enable_extension('pg_trgm')

    change_table :invoice_suppliers do |t|
      t.string :emails, array: true, default: []
      t.string :display_name, null: true
    end

    add_index :invoice_suppliers, :name, name: 'index_invoice_suppliers_on_name_gin', using: 'gin', opclass: :gin_trgm_ops, algorithm: :concurrently
  end
end
