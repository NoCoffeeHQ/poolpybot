# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoicesMailbox, type: :mailbox do
  let!(:user) { create(:user, :with_uuid) }

  subject { receive_inbound_email_from_source(mail.to_s) }

  describe 'Given the email is from Apple' do
    let(:mail) { brevo_mails(:apple).first }

    it 'creates a new invoice' do
      skip 'TODO'
    end
  end

  describe 'Given the email from AWS including a PDF' do
    let(:mail) { brevo_mails(:aws).first }

    it 'creates a new invoice with a PDF attached to it' do
      skip 'TODO'
    end
  end
end
