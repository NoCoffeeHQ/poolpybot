# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mail' do
  describe 'Mail.from_brevo' do
    let(:item) { brevo_items(:apple).first }

    subject { Mail.from_brevo(item) }

    it 'creates a valid Mail instance' do
      expect(subject.message_id).to eq '0E87F473-1E6B-4BFB-84F3-D46CC5682767@gmail.com'
      expect(subject.date).to eq 'Fri, 4 Aug 2023 22:02:27 +0200'
      expect(subject.from).to eq ['didier.lafforgue@gmail.com']
      expect(subject.to).to eq ['a5c656df-c501-4d2c-bf8f-7259c8111991@reply.poolpybot.fr']
      expect(subject.subject).to eq 'Fwd: Votre facture Apple'
      expect(subject.text_part.body.to_s.strip).to match(/^> Begin forwarded message:\r\n> \r\n> From: Apple/)
      expect(subject.html_part.body.to_s.strip).to match(/^<html><head>/)
    end

    describe 'Given the Brevo item includes attachments' do
      let(:item) { brevo_items(:aws).first }

      it 'attaches the Brevo attachments in the Mail instance' do
        expect(subject.subject).to include('Fwd: Amazon Web Services Invoice Available')
        expect(subject.attachments.map(&:filename).sort).to eq(['brevo-attachment-0.json', 'brevo-attachment-1.json'])
      end
    end
  end
end
