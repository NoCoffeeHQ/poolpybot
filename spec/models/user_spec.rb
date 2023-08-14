# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect { create(:user) }.to change(User, :count).by(1)
  end

  it 'generates an uuid' do
    expect(create(:user, :with_uuid).reload.uuid.blank?).to eq false
  end

  describe 'change the password' do
    let(:user) { create(:user) }
    let(:new_password) { 'newpassword'}
    let(:new_password_confirmation) { 'newpassword' }

    before { user.password_confirmation = new_password_confirmation }

    subject { user.change_password(new_password) }

    it { is_expected.to eq true }

    describe 'Given the new password is blank' do
      let(:new_password) { '' }

      it { is_expected.to eq false }
    end

  end
end

# == Schema Information
#
# Table name: users
#
#  id                                  :bigint           not null, primary key
#  access_count_to_reset_password_page :integer          default(0)
#  crypted_password                    :string
#  email                               :string           not null
#  reset_password_email_sent_at        :datetime
#  reset_password_token                :string
#  reset_password_token_expires_at     :datetime
#  salt                                :string
#  username                            :string           not null
#  uuid                                :uuid             not null
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  company_id                          :bigint           not null
#
# Indexes
#
#  index_users_on_company_id            (company_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token)
#  index_users_on_uuid                  (uuid) UNIQUE
#
