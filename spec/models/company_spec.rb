# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company, type: :model do
  it 'has a valid factory' do
    expect { create(:company) }.to change(Company, :count).by(1)
  end

  it 'generates an uuid' do
    expect(create(:company).reload.uuid.blank?).to eq false
  end
end

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
