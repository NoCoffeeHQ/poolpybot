# frozen_string_literal: true

class InvoiceSupplier < ApplicationRecord
  ## associations ##
  belongs_to :company
  has_many :invoices, dependent: :destroy

  ## validations ##
  validates :name, presence: true
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
