# frozen_string_literal: true

class InvoiceSupplier < ApplicationRecord
  ## associations ##
  belongs_to :company
  has_many :invoices, dependent: :destroy
  has_many :sorted_invoices, -> { order(date: :desc) }, class_name: 'Invoice'

  ## validations ##
  validates :name, presence: true

  ## scopes ##
  scope :similar_to, lambda { |n|
                       where(InvoiceSupplier[:name].similar_to(n).gteq(0.6))
                         .order(InvoiceSupplier[:name].similar_to(n).desc)
                     }
  scope :by_email, ->(email) { where('? = ANY(emails)', email) }
  scope :with_invoices, -> { where(InvoiceSupplier[:invoices_count].gt(0)) }
  scope :ordered, -> { order(name: :asc) }

  ## callbacks ##
  before_destroy :cant_delete_if_invoices

  ## virtual attributes ##
  attribute :real_name

  ## methods ##

  def last_invoice
    @last_invoice ||= sorted_invoices.first
  end

  def normalized_name
    (display_name.presence || name).parameterize
  end

  ## class methods ##

  def self.ordered
    column = Arel::Nodes::NamedFunction.new('coalesce', [t[:display_name], t[:name]]).as('real_name')
    select(t[Arel.star], column).order(:real_name)
  end

  ## private methods ##

  def cant_delete_if_invoices
    throw :abort if invoices.count.positive?
  end
end

# == Schema Information
#
# Table name: invoice_suppliers
#
#  id             :bigint           not null, primary key
#  display_name   :string
#  emails         :string           default([]), is an Array
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
