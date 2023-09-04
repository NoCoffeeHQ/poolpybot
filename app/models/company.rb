# frozen_string_literal: true

class Company < ApplicationRecord
  ## associations ##
  has_many :users, dependent: :destroy
  has_many :invoice_suppliers, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :user_invitations, dependent: :destroy
  has_many :notifications, dependent: :destroy

  ## validations ##
  validates :name, presence: true
end

# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
