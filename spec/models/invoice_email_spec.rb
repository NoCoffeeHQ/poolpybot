require 'rails_helper'

RSpec.describe InvoiceEmail, type: :model do
  it 'has a valid factory' do
    expect { create(:invoice_email) }.to change(InvoiceEmail, :count).by(1)
  end
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
