# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ForwardedMail do
  subject { described_class.new(mail) }

  describe 'Given the mail was forwarded from Apple Mail' do
    let(:mail) { brevo_mails(:apple).first }

    it 'is detected as a forwarded email' do
      expect(subject.forwarded?).to eq true
    end

    it 'extracts the original subject' do
      expect(subject.original_subject).to eq 'Votre facture Apple'
    end

    it 'extracts the original from' do
      expect(subject.original_from[:name]).to eq 'Apple'
    end
  end
end
