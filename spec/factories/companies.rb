# frozen_string_literal: true

# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  uuid       :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_companies_on_uuid  (uuid) UNIQUE
#
FactoryBot.define do
  factory :company do
    name { 'Acme Corp' }

    trait :with_uuid do
      uuid { 'a5c656df-c501-4d2c-bf8f-7259c8111991' }
    end
  end
end
