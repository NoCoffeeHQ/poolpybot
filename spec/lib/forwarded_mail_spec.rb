# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ForwardedMail do
  describe 'Given the mail was forwarded from Apple Mail' do
    subject { mail(:apple) }

    it 'is detected as a forwarded email' do
      expect(subject.forwarded?).to eq true
    end

    it 'extracts the original subject' do
      expect(subject.original_subject).to eq 'Votre facture Apple'
    end

    it 'extracts the original from' do
      expect(subject.original_from[:name]).to eq 'Apple'
    end

    it 'extracts original text' do
      expect(subject.original_text_body).to include('Amex .... 1006')
      expect(subject.original_text_body).not_to include('Begin forwarded message:')
      expect(subject.original_text_body).not_to include('Subject: Votre facture Apple')
      expect(subject.original_text_body).not_to include('From: Apple <no_reply@email.apple.com>')
      expect(subject.original_text_body).not_to include('Date: August 4, 2023 at 4:07:52 PM GMT+2')
      expect(subject.original_text_body).not_to include('To: didier.lafforgue@icloud.com')
    end
  end

  describe 'Given the mail is an invoice from Akamai' do
    subject { mail(:akamai) }

    it 'is detected as a forwarded email' do
      expect(subject.forwarded?).to eq true
    end

    it 'extracts the original subject' do
      expect(subject.original_subject).to eq 'Linode (Akamai Cloud Computing) - Invoice [24519850]'
    end

    it 'extracts the original from' do
      expect(subject.original_from[:name]).to eq nil
      expect(subject.original_from[:address]).to eq 'billing@linode.com'
    end

    it 'extracts original text' do
      expect(subject.original_text_body).to include('Akamai Technologies International AG')
      expect(subject.original_text_body).not_to include('Begin forwarded message:')
      expect(subject.original_text_body).not_to include('Subject: Linode (Akamai Cloud Computing) - Invoice [24519850]')
      expect(subject.original_text_body).not_to include('From: billing@linode.com')
      expect(subject.original_text_body).not_to include('Date: September 1, 2023 at 9:44:28 AM GMT+2')
      expect(subject.original_text_body).not_to include('To: did@locomotivecms.com, estelle@locomotivecms.com')
    end
  end
end
