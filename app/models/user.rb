# frozen_string_literal: true

class User < ApplicationRecord
  ## associations ##
  belongs_to :company
  has_many :invoices, dependent: :destroy

  ## attachments ##
  has_one_attached :avatar

  ## validations ##
  validates :username, presence: true
  validates :email, email: true, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, if: :enable_password_validation?
  validates :password_confirmation, presence: true, if: :enable_password_validation?
  validates :password, confirmation: true, if: :enable_password_validation?
  validates :avatar, blob: { content_type: :image, size_range: 1..(1.megabytes) }

  ## callbacks ##
  before_destroy :cant_delete_if_invoices

  ## behaviors ##
  authenticates_with_sorcery!

  ## virtual attributes ##
  attr_accessor :changing_password

  ## methods ##
  def reply_email
    "#{ENV['INBOUND_REPLY_EMAIL_NAME']} <#{uuid}@#{ENV['INBOUND_REPLY_EMAIL_DOMAIN']}>"
  end

  def change_password(new_password, raise_on_failure: false)
    @changing_password = true
    super
  end

  def changing_password?
    !!@changing_password
  end

  private

  def cant_delete_if_invoices
    throw :abort if invoices.count.positive?
  end

  def enable_password_validation?
    new_record? || changes[:crypted_password] || changing_password?
  end
end

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
