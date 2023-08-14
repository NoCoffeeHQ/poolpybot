# frozen_string_literal: true

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
FactoryBot.define do
  factory :user do
    company { Company.first || create(:company) }
    username { 'Ernest' }
    email { 'ernest@acme.org' }
    password { 'easyone' }
    password_confirmation { 'easyone' }

    trait :with_uuid do
      uuid { 'a5c656df-c501-4d2c-bf8f-7259c8111991' }
    end
  end
end
