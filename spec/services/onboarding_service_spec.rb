# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OnboardingService do
  let(:container) { ApplicationContainer.new }
  let(:instance) { container.onboarding }

  describe '#call' do
    let(:company) { build(:company) }
    let(:user) { build(:user, company: nil) }
    
    subject { instance.call(company: company, user: user) }

    it { is_expected.to eq true }

    it 'persists the company and the user in DB' do
      expect { subject }.to change(Company, :count).by(1).and change(User, :count).by(1)
    end

    describe 'Given the company is not valid' do
      let(:company) { build(:company, name: nil) }

      it { is_expected.to eq false }

      it 'doesn\'t persist the company and the user' do
        expect { subject }.to change(Company, :count).by(0).and change(User, :count).by(0)
      end
    end
  end
  
end