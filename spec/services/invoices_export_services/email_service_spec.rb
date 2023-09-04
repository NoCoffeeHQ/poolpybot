# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoicesExportServices::EmailService do
  let(:instance) { described_class.new({}) }
  let!(:user) { create(:user) }
  let(:date) { Time.zone.today }

  subject { instance.call(user: user, date: date) }

  describe 'Given there are no invoices for the month' do
    it 'doesn\'t send an email' do
      expect do
        subject
      end.not_to(change { ActionMailer::Base.deliveries.size })
    end
  end

  describe 'Given there are invoices for the month' do
    before do
      create(:invoice, :processed, :apple_pdf)
      create(:invoice, :processed, :aws_pdf)
      create(:invoice, :processed, :aws_pdf, date: 2.months.ago, external_id: 'aws-fake-uuid-old')
    end

    it 'creates a zip file?' do
      expect(File.size(subject.path)).to be >= 63_438
      expect(`file --b --mime-type '#{subject.path}'`.strip).to eq 'application/zip'
    end

    it 'sends an email to the user' do
      expect(UserMailer).to receive(:invoices_export).and_call_original
      subject
    end
  end
end
