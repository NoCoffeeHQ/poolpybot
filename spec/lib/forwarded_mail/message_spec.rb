# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ForwardedMail::Message do
  describe 'Given the email is not a forward' do
    let(:message) { brevo_mails(:sendgrid).first }

    it 'has a from_address attribute' do
      expect(message.from_address).to eq 'noreply@sendgrid.com'
    end

    it 'has a from_name attribute' do
      expect(message.from_name).to eq 'SendGrid'
    end

    describe 'Given the email is from Plausible' do
      let(:message) { fetch_mail(:plausible_original) }

      it 'has a text body with urls' do
        expect(message.text_body).to include('http://my.paddle.com/receipt/42574047-87718652/180040006-chrec6efd2523ae-af8d29169a')
      end
    end
  end
  describe 'Given the email is a forward' do
    describe 'Given the original email is from Plausible' do
      let(:message) { fetch_mail(:plausible) }

      it 'has a text body with urls' do
        expect(message.text_body).to include('http://my.paddle.com/receipt/42574047-87718652/180040006-chrec6efd2523ae-af8d29169a')
      end
    end
  end
end
