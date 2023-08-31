# frozen_string_literal: true

class InvoiceEmail < ApplicationRecord
  ## associations ##
  belongs_to :invoice

  ## validations ##
  validates :subject, :from, :forwarded_at, presence: true
end

# == Schema Information
#
# Table name: invoice_emails
#
#  id           :bigint           not null, primary key
#  forwarded_at :datetime
#  from         :string
#  name         :string
#  subject      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  invoice_id   :bigint           not null
#
# Indexes
#
#  index_invoice_emails_on_invoice_id  (invoice_id)
#
# Foreign Keys
#
#  fk_rails_...  (invoice_id => invoices.id)
#
