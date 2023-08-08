# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect { create(:user) }.to change(User, :count).by(1)
  end

  it 'generates an uuid' do
    expect(create(:user, :with_uuid).reload.uuid.blank?).to eq false
  end
end

# == Schema Information
#
# Table name: users
#
#  id               :bigint           not null, primary key
#  crypted_password :string
#  email            :string           not null
#  salt             :string
#  username         :string           not null
#  uuid             :uuid             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  company_id       :bigint           not null
#
# Indexes
#
#  index_users_on_company_id  (company_id)
#  index_users_on_email       (email) UNIQUE
#  index_users_on_uuid        (uuid) UNIQUE
#
