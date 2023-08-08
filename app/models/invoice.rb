# frozen_string_literal: true

class Invoice < ApplicationRecord
  ## enums ##
  enum :status, %i[created processed failed]

  ## associations ##
  belongs_to :company
  belongs_to :user
  belongs_to :invoice_supplier, optional: true

  ## validations ##
  validates :external_id, presence: true, uniqueness: { scope: :company_id }

  ## attachments ##
  has_one_attached :pdf_document
end

# == Schema Information
#
# Table name: invoices
#
#  id                  :bigint           not null, primary key
#  currency            :string
#  date                :date
#  error               :string
#  status              :integer          default("created")
#  tax_rate            :float
#  total_amount        :float
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  company_id          :bigint           not null
#  external_id         :string           not null
#  invoice_supplier_id :bigint
#  user_id             :bigint           not null
#
# Indexes
#
#  index_invoices_on_company_id                  (company_id)
#  index_invoices_on_company_id_and_external_id  (company_id,external_id) UNIQUE
#  index_invoices_on_invoice_supplier_id         (invoice_supplier_id)
#  index_invoices_on_user_id                     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (invoice_supplier_id => invoice_suppliers.id)
#  fk_rails_...  (user_id => users.id)
#
