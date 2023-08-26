require 'rails_helper'

RSpec.describe UserInvitation, type: :model do
  it 'has a valid factory' do
    expect { create(:user_invitation) }.to change(UserInvitation, :count).by(1)
  end

  describe '.invite' do
    let(:email) { 'jane@doe.net' }
    let!(:user) { create(:user) }

    subject { described_class.invite(email: email, invited_by: user) }

    describe 'Given there is no one in the company with this email' do
      it 'creates an invitation' do
        expect { subject }.to change(UserInvitation, :count).by(1)
      end
      it 'sets a new token' do
        expect(subject.token).not_to be nil
      end
      it 'sends the invitation by mail' do
        expect(UserMailer).to receive(:send_invitation).and_call_original
        subject
      end
    end

    describe 'Given there is an existing user with this email' do
      let!(:invited_user) { create(:user, email: email, company: company) }

      describe 'Given this user is already part of this company' do
        let(:company) { user.company }

        it 'doesn\'t create an invitation' do
          expect { subject }.to change(UserInvitation, :count).by(0)
        end

        it 'tracks the error in the email field' do
          expect(subject.errors[:email]).to eq(['is already in the company'])
        end
      end

      describe 'Given this user is not part of this company' do
        let(:company) { create(:company, name: 'FooBar Inc.') }

        describe 'Given the user has no invoices' do
          it 'creates an invitation' do
            expect { subject }.to change(UserInvitation, :count).by(1)
          end
        end

        describe 'Given the user has already imported invoices' do
          let!(:invoice) { create(:invoice, company: company, user: invited_user) }

          it 'doesn\'t create an invitation' do
            expect { subject }.to change(UserInvitation, :count).by(0)
          end

          it 'tracks the error in the email field' do
            expect(subject.errors[:email]).to eq(['has already collected invoices for another company'])
          end
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: user_invitations
#
#  id         :bigint           not null, primary key
#  email      :string
#  expired_at :datetime         not null
#  token      :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :bigint           not null
#  user_id    :bigint
#
# Indexes
#
#  index_company_user_invitation_uniqueness  (company_id,email) UNIQUE
#  index_user_invitations_on_company_id      (company_id)
#  index_user_invitations_on_token           (token) UNIQUE
#  index_user_invitations_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (user_id => users.id)
#
