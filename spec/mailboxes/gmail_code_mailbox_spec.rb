# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GmailForwardingCodeMailbox, type: :mailbox do
  let!(:user) { create(:user, :with_uuid) }

  subject { receive_inbound_email_from_source(mail.to_s) }

  describe 'Given the email has been sent by the Google code verification service' do
    let(:mail) { brevo_mails('gmail_verification_code').first }

    it 'forwards the email to the user' do
      expect do
        subject
      end.to(change { ActionMailer::Base.deliveries.size }.by(1))
    end
  end
end
