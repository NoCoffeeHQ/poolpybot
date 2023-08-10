# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoicesMailbox, type: :mailbox do
  let(:container) { build_application_container_mock }
  let!(:user) { create(:user, :with_uuid) }

  before do
    allow_any_instance_of(InvoicesMailbox).to receive(:application_container).and_return(container)
  end

  subject { receive_inbound_email_from_source(mail.to_s) }

  describe 'Given the email is from Apple' do
    let(:mail) { brevo_mails(:apple).first }

    it 'creates a new invoice' do
      expect(container.mail_invoice_creator).to receive(:call).once
      subject
    end
  end

  describe 'Given the email from AWS including a PDF' do
    let(:mail) { brevo_mails(:aws).first }

    it 'creates a new invoice with a PDF attached to it' do
      expect_any_instance_of(BrevoRuby::InboundParsingApi).to receive(:get_inbound_email_attachment).once.and_return(StringIO.new('Hello!'))
      expect(container.mail_invoice_creator).to receive(:call).once
      subject
    end
  end
end
