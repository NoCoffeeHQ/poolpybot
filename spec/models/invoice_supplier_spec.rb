# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceSupplier, type: :model do
  it 'has a valid factory' do
    expect { create(:invoice_supplier) }.to change(InvoiceSupplier, :count).by(1)
  end

  describe '.similar_to' do
    let(:query) { 'github' }

    before do
      create(:invoice_supplier, name: 'GitHub, Inc.')
      create(:invoice_supplier, name: 'Gitlab')
    end

    subject { described_class.similar_to(query).first&.name }

    it 'returns a supplier which has a name simlar to the query' do
      is_expected.to eq 'GitHub, Inc.'
    end

    describe 'Given the query is about a name which doesn\'t exist in our DB' do
      let(:query) { 'Gitbook' }
      it { is_expected.to eq nil }
    end
  end
end

# == Schema Information
#
# Table name: invoice_suppliers
#
#  id           :bigint           not null, primary key
#  display_name :string
#  emails       :string           default([]), is an Array
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  company_id   :bigint           not null
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
