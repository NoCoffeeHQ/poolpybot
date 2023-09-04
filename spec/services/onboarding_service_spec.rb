# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OnboardingService do
  let(:container) { ApplicationContainer.new }
  let(:instance) { container.onboarding }

  describe '#call' do
    let(:company) { build(:company) }
    let(:user) { build(:user, :john_doe, company: nil) }
    let(:invitation) { nil }

    subject { instance.call(company: company, user: user, invitation: invitation) }

    it { is_expected.to eq true }

    it 'persists the company and the user in DB' do
      expect { subject }.to change(Company, :count).by(1).and change(User, :count).by(1)
    end

    it 'creates 2 notifications' do
      expect { subject }.to change(Notification, :count).by(2)
    end

    describe 'Given the company is not valid' do
      let(:company) { build(:company, name: nil) }

      it { is_expected.to eq false }

      it 'doesn\'t persist the company and the user' do
        expect { subject }.to change(Company, :count).by(0).and change(User, :count).by(0)
      end
    end

    describe 'Given the user signs up from an invitation' do
      let!(:invitation) { create(:user_invitation) }

      it 'only persists the user in DB' do
        expect { subject }.to change(Company, :count).by(0).and change(User, :count).by(1)
      end

      it 'creates 1 notification' do
        expect { subject }.to change(Notification, :count).by(1)
      end

      it 'deletes the invitation' do
        expect { subject }.to change(UserInvitation, :count).by(-1)
      end
    end
  end
end
