class CreateInvoiceEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :invoice_emails do |t|
      t.references :invoice, null: false, foreign_key: true
      t.string :subject
      t.string :from
      t.string :name
      t.datetime :forwarded_at
      
      t.timestamps
    end
  end
end
