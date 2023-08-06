# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceSupplier, type: :model do
  it 'has a valid factory' do
    expect { create(:invoice_supplier) }.to change(InvoiceSupplier, :count).by(1)
  end
end

# == Schema Information
#
# Table name: invoice_suppliers
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :bigint           not null
#
# Indexes
#
#  index_invoice_suppliers_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#
