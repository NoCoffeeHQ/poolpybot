class Notification < ApplicationRecord
  ## concerns ##
  include ::TranslateEnum

  ## enums ##
  enum :event, %i[company_created user_joined invitation_sent email_processed email_not_processed uploaded_pdf_processed uploaded_pdf_not_processed]

  ## associations ##
  belongs_to :company
  belongs_to :user

  ## validations ##
  validates :event, presence: true

  ## scopes ##
  scope :optimized, -> { includes(:company, user: [:avatar_attachment]).joins(:company, :user) }
  scope :ordered, -> { order(created_at: :desc) }

  ## methods ##

  def full_data
    (data || {}).merge(
      company: company.name,
      username: user.username,
    ).deep_symbolize_keys
  end

  def send_email?
    email_processed? || uploaded_pdf_processed?
  end

  def send_email
    return unless send_email?
    UserMailer.notify(self).deliver_later 
  end

  ## class methods ##

  def self.read?(user)
    return true if user.notifications_read_at.blank?
    where(
      Notification[:created_at].gt(user.notifications_read_at)
    ).exists?
  end

  def self.trigger(user:, event:, data: {})
    Notification.create(
      company: user.company,
      user: user,
      event: event,
      data: data
    ).tap do |notification|
      notification.send_email
    end
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
