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
  end
end
