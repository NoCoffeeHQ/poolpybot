# frozen_string_literal: true

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
FactoryBot.define do
  factory :invoice_supplier do
    company { Company.first || create(:company) }
    name { 'Apple' }
  end
end
