# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification, type: :model do
  it 'has a valid factory' do
    expect { create(:notification) }.to change(Notification, :count).by(1)
  end
end

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
