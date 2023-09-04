# == Schema Information
#
# Table name: notifications
#
#  id         :bigint           not null, primary key
#  data       :jsonb
#  event      :integer          default("company_created")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_notifications_on_company_id  (company_id)
#  index_notifications_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :notification do
    company { create(:company) }
    user { create(:user) }
    event { :company_created }
    data { {} }

    trait :email_processed do 
      event { :email_processed }
      data { { subject: 'Your invoice', from: 'accouting@acme.org' } }
    end
  end
end
