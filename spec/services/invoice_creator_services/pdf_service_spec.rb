# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceCreatorServices::PdfService do
  let(:container) { build_application_container_mock }
  let(:instance) { container.pdf_invoice_creator }
  let(:user) { create(:user, :with_uuid) }
  let(:parser_response) { nil }
  let(:pdf) { attachable_pdf(File.open(file_fixture('invoices/apple.pdf').to_s)) }
  let(:pdf_text) { 'information about the invoice' }

  before do
    allow(container.invoice_parser).to receive(:call).and_return(parser_response)
    allow(container.pdf_to_text).to receive(:call).and_return(pdf_text)
  end

  subject { instance.call(user: user, pdf: pdf) }

  describe 'Given our AI was able to extract the information out of the PDF' do
    let(:parser_response) { 
      { 
        company_name: 'Apple', date: '2023/06/26', identifier: 'INVOICE-1', 
        total_amount: 12.99, tax_rate: 2.1, currency: 'EUR'
      } 
    }
    
    it 'creates the invoice in DB' do
      expect { subject }.to change(Invoice, :count).by(1).and change(InvoiceSupplier, :count).by(1)
    end

    it 'returns a processed invoice' do
      expect(subject.processed?).to eq true
      expect(subject.invoice_supplier.name).to eq 'Apple'
      expect(subject.total_amount).to eq 12.99
      expect(subject.currency).to eq 'EUR'
      expect(subject.date.to_s).to eq '2023-06-26'
    end

    it 'attaches the source PDF to the invoice' do
      expect(subject.pdf_document.attached?).to eq true
    end

    describe 'Given we try to process twice the same PDF' do
      let(:another_pdf) { attachable_pdf(File.open(file_fixture('invoices/apple.pdf').to_s)) }
      before { instance.call(user: user, pdf: another_pdf) }

      it 'returns a failed invoice' do
        expect(subject.failed?).to eq true
        expect(subject.duplicated_error?).to eq true
        expect(subject.duplicate_of).not_to be nil
      end
    end
  end

  describe 'Given our AI wasn\'t able to extract the information out of the PDF' do
    let(:parser_response) { nil }

    it 'creates an invoice in DB' do
      expect { subject }.to change(Invoice, :count).by(1).and change(InvoiceSupplier, :count).by(0)
    end

    it 'returns a failed invoice' do
      expect(subject.failed?).to eq true
      expect(subject.parse_with_ai_error?).to eq true
    end

    it 'attaches the source PDF to the invoice' do
      expect(subject.pdf_document.attached?).to eq true
    end
  end
end

