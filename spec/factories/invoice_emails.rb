# frozen_string_literal: true

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
FactoryBot.define do
  factory :invoice_email do
    invoice { Invoice.last || create(:invoice) }
    name { 'Acme' }
    subject { 'Your invoice' }
    from { 'accouting@acme.org' }
    forwarded_at { 1.day.from_now }
  end
end
