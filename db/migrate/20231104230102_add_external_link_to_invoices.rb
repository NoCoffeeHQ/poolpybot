class AddExternalLinkToInvoices < ActiveRecord::Migration[7.1]
  def change
    add_column :invoices, :external_link, :string, default: nil
  end
end
