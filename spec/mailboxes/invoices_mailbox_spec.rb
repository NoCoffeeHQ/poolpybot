# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoicesMailbox, type: :mailbox do
  let(:container) { build_application_container_mock }
  let!(:user) { create(:user, :with_uuid) }

  before do
    allow_any_instance_of(InvoicesMailbox).to receive(:application_container).and_return(container)
  end

  describe 'Given the Mailbox ingress is Sendgrid' do
    subject { receive_inbound_email_from_fixture("mails/#{name}.eml") }

    describe 'Given the email is an invoice from Amazon' do
      let(:name) { :amazon }

      it 'creates a new invoice' do
        expect(container.mail_invoice_creator).to receive(:call).once
        subject
      end
    end

    describe 'Given the email is an invoice from Apple' do
      let(:name) { :apple }

      it 'creates a new invoice' do
        expect(container.mail_invoice_creator).to receive(:call).once
        subject
      end
    end
  end

  describe 'Given the Mailbox ingress is Brevo' do
    subject { receive_inbound_email_from_source(mail.to_s) }

    describe 'Given the email is an invoice from Apple' do
      let(:mail) { brevo_mails(:apple).first }

      it 'creates a new invoice' do
        expect(container.mail_invoice_creator).to receive(:call).once
        subject
      end
    end

    describe 'Given the email has been forwarded from a Gmail rule' do
      let(:mail) { brevo_mails(:sendgrid).first }

      it 'creates a new invoice' do
        expect(container.mail_invoice_creator).to receive(:call).once
        subject
      end
    end

    describe 'Given the email from Amazon including a PDF' do
      let(:mail) { brevo_mails(:aws).first }

      it 'creates a new invoice with a PDF attached to it' do
        expect_any_instance_of(BrevoRuby::InboundParsingApi).to receive(
          :get_inbound_email_attachment
        ).once.and_return(File.open(file_fixture('invoices/aws.pdf')))
        expect(container.mail_invoice_creator).to receive(:call).once
        subject
      end
    end
  end
end
