# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'reset_password_email' do
    let(:user) { create(:user) }
    let(:mail) { UserMailer.reset_password_email(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Reset your password')
      expect(mail.to).to eq(['ernest@acme.org'])
      expect(mail.from).to eq(['from@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Hello, Ernest')
    end
  end

  describe 'send_invitation_email' do
    let(:invitation) { create(:user_invitation).reload }
    let(:mail) { UserMailer.send_invitation(invitation, true) }

    it 'renders the headers' do
      expect(mail.subject).to eq('You\'ve been invited to join Poolpybot!')
      expect(mail.to).to eq(['john@doe.net'])
      expect(mail.from).to eq(['from@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match(
        'Ernest from Acme Corp has invited you to join Poolpybot to collect invoices of your company.'
      )
    end
  end

  describe 'invoices_export' do 
    let(:user) { create(:user) }
    let(:date) { Date.today }
    let(:zipfile) { File.open(Rails.root.join("spec/fixtures/files/invoices/apple.pdf").to_s) }
    let(:mail) { UserMailer.invoices_export(user, date, zipfile) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Your invoices collected by Poolpybot')
      expect(mail.to).to eq(['ernest@acme.org'])
      expect(mail.from).to eq(['from@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Hello, Ernest')
    end
  end
end
