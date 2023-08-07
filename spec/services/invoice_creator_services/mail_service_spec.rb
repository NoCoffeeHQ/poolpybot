# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceCreatorServices::MailService do
  let(:container) { ApplicationContainer.new }
  let(:instance) { container.mail_invoice_creator }
  let!(:user) { create(:user) }

  subject { instance.call(mail: mail) }

  describe 'Given the email is a forward of an Apple Invoice' do
    let(:mail) { brevo_mails(:apple).first }

    it 'creates the invoice in DB' do
      skip 'TODO....🚧'
      # expect { subject }.to change(Invoice, :count).by(1)
    end
  end
end
