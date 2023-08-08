# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceCreatorServices::MailService do
  let(:container) { build_application_container_mock }
  let(:instance) { container.mail_invoice_creator }
  let!(:user) { create(:user, :with_uuid) }
  let(:parser_response) { nil }

  before do
    allow(container.invoice_parser).to receive(:call).and_return(parser_response)
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

      describe 'Given we try to process twice the same mail' do
        before { instance.call(mail: mail) }

        it "doesn\'t create a duplicated invoice in DB" do
          expect { subject }.not_to change(Invoice, :count)
        end
      end
    end
  end
end
