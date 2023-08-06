# frozen_string_literal: true

class Company < ApplicationRecord
  ## associations ##
  has_many :users, dependent: :destroy
  has_many :invoice_suppliers, dependent: :destroy

  ## validations ##
  validates :name, presence: true
  # validates :uuid, presence: true, uniqueness: true
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
