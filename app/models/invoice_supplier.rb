# frozen_string_literal: true

class InvoiceSupplier < ApplicationRecord
  ## associations ##
  belongs_to :company
  has_many :invoices, dependent: :destroy

  ## validations ##
  validates :name, presence: true

  ## scopes ##
  scope :similar_to, lambda { |n|
                       where(InvoiceSupplier[:name].similar_to(n).gteq(0.6))
                         .order(InvoiceSupplier[:name].similar_to(n).desc)
                     }

  scope :by_email, ->(email) { where('? = ANY(emails)', email) }

  ## methods ##

  def display_name
    super.presence || name
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
