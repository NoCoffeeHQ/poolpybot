# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_suppliers
#
#  id             :bigint           not null, primary key
#  display_name   :string
#  emails         :string           default([]), is an Array
#  follow_link    :boolean          default(FALSE)
#  invoices_count :integer
#  name           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  company_id     :bigint           not null
#
# Indexes
#
#  index_invoice_suppliers_on_company_id  (company_id)
#  index_invoice_suppliers_on_name_gin    (name) USING gin
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
