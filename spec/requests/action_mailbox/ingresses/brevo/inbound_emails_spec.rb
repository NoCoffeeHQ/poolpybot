# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ActionMailbox::Ingresses::Brevo::InboundEmails', type: :request do
  describe 'POST /rails/action_mailbox/brevo/inbound_emails/:password', skip: ENV['INBOUND_INGRESS'] != 'brevo' do
    let(:params) { { items: brevo_items(:apple) } }
    it 'returns http success' do
      expect(ActionMailbox::InboundEmail).to receive(:create_and_extract_message_id!).once
      post '/rails/action_mailbox/brevo/inbound_emails/helloworld', params: params, as: :json
      expect(response).to have_http_status(:success)
    end
  end
end
