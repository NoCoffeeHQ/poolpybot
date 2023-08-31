# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ForwardedMail::Parser do
  subject { described_class.call(mail: mail) }

  describe 'Given the mail was forwarded from Apple Mail' do
    let(:mail) { brevo_mails(:apple).first }

    it 'extracts the original subject' do
      expect(subject[:subject]).to eq 'Votre facture Apple'
    end

    it 'extracts the original from' do
      expect(subject[:from]).to eq({ name: 'Apple', address: 'no_reply@email.apple.com' })
    end

    it 'removes the extra header added when the mail was forwarded' do
      expect(subject[:html_body]).not_to include('Begin forwarded message')
      expect(subject[:html_body]).to include('N° DE COMMANDE')
    end
  end
end
