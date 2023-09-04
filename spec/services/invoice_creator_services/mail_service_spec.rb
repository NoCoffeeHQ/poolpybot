# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceCreatorServices::MailService do
  let(:container) { build_application_container_mock }
  let(:instance) { container.mail_invoice_creator }
  let!(:user) { create(:user, :with_uuid) }
  let(:parser_response) { nil }
  let(:pdf_io) { nil }

  before do
    allow(container.invoice_parser).to receive(:call).and_return(parser_response)
    allow(container.html_to_pdf).to receive(:call).and_return(pdf_io)
  end

  subject { instance.call(mail: mail) }

  describe 'Given the email is a forward of an Apple Invoice' do
    let(:mail) { brevo_mails(:apple).first }

    describe 'Given the mail address doesn\'t belong to an user' do
      let!(:user) { create(:user) }

      it 'doesn\'t create the invoice in DB' do
        expect { subject }.not_to change(Invoice, :count)
      end

      it 'returns nil' do
        is_expected.to eq nil
      end
    end

    describe 'Given our AI was able to extract the information out of the email body' do
      let(:parser_response) do
        {
          company_name: 'Apple', date: '2023/06/26', identifier: 'INVOICE-1',
          total_amount: 12.99, tax_rate: 2.1, currency: 'EUR'
        }
      end
      let(:pdf_io) { StringIO.new('randombytes') }

      it 'creates the invoice in DB' do
        expect { subject }.to change(Invoice, :count).by(1)
                                                     .and(change(InvoiceSupplier, :count).by(1))
                                                     .and(change(InvoiceEmail, :count).by(1))
                                                     .and(change(Notification, :count).by(1))
      end

      it 'sends a notification email' do

      end

      it 'returns a processed invoice' do
        expect(subject.processed?).to eq true
        expect(subject.invoice_supplier.name).to eq 'Apple'
        expect(subject.invoice_supplier.emails).to eq ['no_reply@email.apple.com']
        expect(subject.total_amount).to eq 12.99
        expect(subject.currency).to eq 'EUR'
        expect(subject.date.to_s).to eq '2023-06-26'
      end

      it 'generates a PDF out of the HTML part' do
        expect(subject.pdf_document.attached?).to eq true
      end

      it 'tracks the most important information of the email' do
        expect(subject.invoice_email.subject).to eq 'Votre facture Apple'
        expect(subject.invoice_email.name).to eq 'Apple'
        expect(subject.invoice_email.from).to eq 'no_reply@email.apple.com'
      end

      describe 'Given we try to process twice the same mail' do
        before { instance.call(mail: mail) }

        it "doesn\'t create a duplicated invoice in DB" do
          expect { subject }.not_to change(Invoice, :count)
          expect(subject.external_id).to eq 'INVOICE-1'
        end
      end
    end

    describe 'Given our AI wasn\'t able to extract the information out of the mail body' do
      let(:parser_response) { nil }

      it 'creates an invoice in DB' do
        expect { subject }.to change(Invoice, :count).by(1)
                                                     .and(change(InvoiceSupplier, :count).by(0))
                                                     .and(change(InvoiceEmail, :count).by(1))
                                                     .and(change(Notification, :count).by(1))
      end

      it 'tracks the most important information of the email' do
        expect(subject.invoice_email.subject).to eq 'Votre facture Apple'
        expect(subject.invoice_email.name).to eq 'Apple'
        expect(subject.invoice_email.from).to eq 'no_reply@email.apple.com'
      end

      it 'returns a failed invoice' do
        expect(subject.failed?).to eq true
        expect(subject.parse_with_ai_error?).to eq true
      end

      it 'attaches the source PDF to the invoice' do
        skip 'Not sure if we need this "feature" right now'
        expect(subject.pdf_document.attached?).to eq true
      end
    end
  end

  describe 'Given the email is a forward of a AWS Invoice with an attached PDF' do
    let(:mail) { brevo_mails(:aws).first }
    let(:parser_response) do
      {
        company_name: 'AWS', date: '2023/07/01', identifier: 'INVOICE-2',
        total_amount: 0.99, tax_rate: 0.0, currency: 'USD'
      }
    end
    let(:pdf_file) { File.open(file_fixture('invoices/aws.pdf').to_s) }
    let(:pdf_text) { 'information about the AWS invoice' }
    let(:brevo_parsing_api) { instance_double('FakeInboundParsingApi', get_inbound_email_attachment: pdf_file) }

    before do
      allow(container.pdf_to_text).to receive(:call).and_return(pdf_text)
      # Download all the attachments from Brevo (stub mode)
      Mail.brevo_decode_attachments(mail, only_pdf: true, api_instance: brevo_parsing_api)
    end

    it 'creates the invoice in DB' do
      expect { subject }.to change(Invoice, :count).by(1).and change(InvoiceSupplier, :count).by(1)
    end

    it 'returns a processed invoice' do
      expect(subject.processed?).to eq true
      expect(subject.invoice_supplier.name).to eq 'AWS'
    end

    it 'attaches the PDF' do
      expect(subject.pdf_document.attached?).to eq true
    end
  end
end
