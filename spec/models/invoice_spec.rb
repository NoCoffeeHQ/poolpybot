# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice, type: :model do
  it 'has a valid factory' do
    expect { create(:invoice) }.to change(Invoice, :count).by(1)
  end

  it 'reverse calculates the tax amount' do
    invoice = build(:invoice, :with_tax_rate)
    expect(invoice.tax_amount).to eq 0.16
  end

  describe '.grouped_months' do
    before do
      [Date.parse('2023-08-23'), Date.parse('2023-08-22'), 
        Date.parse('2023-07-15'), Date.parse('2022-09-16')].each do |date|
        create(:invoice, :random_external_id, date: date)
      end
    end

    subject { described_class.grouped_months }

    it { is_expected.to eq([
      [2023, [Date.parse('2023-08-01'), Date.parse('2023-07-01')]],
      [2022, [Date.parse('2022-09-01')]]
    ]) }
  end
end

# == Schema Information
#
# Table name: invoices
#
#  id                  :bigint           not null, primary key
#  currency            :string
#  date                :date
#  error               :integer          default("none")
#  status              :integer          default("created")
#  tax_rate            :float
#  total_amount        :float
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  company_id          :bigint           not null
#  duplicate_of_id     :bigint
#  external_id         :string
#  invoice_supplier_id :bigint
#  user_id             :bigint           not null
#
# Indexes
#
#  index_invoices_on_company_id                  (company_id)
#  index_invoices_on_company_id_and_external_id  (company_id,external_id) UNIQUE
#  index_invoices_on_duplicate_of_id             (duplicate_of_id)
#  index_invoices_on_invoice_supplier_id         (invoice_supplier_id)
#  index_invoices_on_user_id                     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (duplicate_of_id => invoices.id)
#  fk_rails_...  (invoice_supplier_id => invoice_suppliers.id)
#  fk_rails_...  (user_id => users.id)
#
