# frozen_string_literal: true

class User < ApplicationRecord
  ## associations ##
  belongs_to :company
  has_many :invoices, dependent: :destroy

  ## validations ##
  validates :username, presence: true
  validates :email, email: true, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  ## callbacks ##
  before_destroy :cant_delete_if_invoices

  ## behaviors ##
  authenticates_with_sorcery!

  ## methods ##
  def reply_email
    "#{uuid}@#{ENV['INBOUND_REPLY_EMAIL_DOMAIN']}"
  end

  private

  def cant_delete_if_invoices
    throw :abort if invoices.count.positive?
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
