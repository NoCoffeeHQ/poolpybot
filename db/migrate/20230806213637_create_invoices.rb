class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.references :company, null: false, foreign_key: true
      t.references :invoice_supplier, null: true, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :message_id, null: false
      t.integer :status, default: 0
      t.date :date, null: true
      t.float :total_amount, null: true
      t.float :tax_rate, null: true
      t.string :currency, null: true

      t.timestamps
    end
  end
end
