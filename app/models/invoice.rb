# frozen_string_literal: true

class Invoice < ApplicationRecord
  ## enums ##
  enum :status, %i[created processing processed failed]
  enum :error, %i[none unknown parse_with_ai extract_text duplicated missing_identifier], suffix: true

  ## associations ##
  belongs_to :company
  belongs_to :user
  belongs_to :invoice_supplier, optional: true
  belongs_to :duplicate_of, class_name: 'Invoice', optional: true

  ## validations ##
  validates :external_id, uniqueness: { scope: :company_id }, if: -> { processed? }

  ## attachments ##
  has_one_attached :pdf_document
  has_one_attached :html_document

  ## methods ##

  def supplier
    invoice_supplier
  end

  def tax_amount
    return 0.0 if tax_rate.blank? || tax_rate.zero? || total_amount.zero?
    (total_amount * (1.0 - (1 / (1.0 + tax_rate.to_f / 100.0)).to_f)).round(2)
  end

  def currency_symbol
    case currency
    when 'EUR' then '€'
    when 'USD' then '$'
    else '?'
    end
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
