# frozen_string_literal: true

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
#  user_id    :bigint           not null
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
FactoryBot.define do
  factory :user_invitation do
    company { Company.first || create(:company) }
    invited_by { create(:user) }
    expired_at { 1.day.from_now }
    email { 'john@doe.net' }
    token { 'arandomtoken' }
  end
end
