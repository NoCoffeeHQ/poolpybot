# frozen_string_literal: true

class Notification < ApplicationRecord
  ## concerns ##
  include ::TranslateEnum

  ## enums ##
  enum :event,
       %i[company_created user_joined invitation_sent email_processed email_not_processed uploaded_pdf_processed
          uploaded_pdf_not_processed]

  ## associations ##
  belongs_to :company
  belongs_to :user

  ## validations ##
  validates :event, presence: true

  ## scopes ##
  scope :optimized, -> { includes(:company, user: [:avatar_attachment]).joins(:company, :user) }
  scope :ordered, -> { order(created_at: :desc) }
  scope :created_on, ->(date) { where(Notification[:created_at].between(date.beginning_of_day..date.end_of_day)) }
  scope :created_between, lambda { |begin_date, end_date|
                            where(Notification[:created_at].between(begin_date.beginning_of_day..end_date.end_of_day))
                          }

  ## methods ##

  def invoice_id
    data['invoice_id']
  end

  def failed_event?
    %i[email_not_processed uploaded_pdf_not_processed].include?(event.to_sym)
  end

  def full_data
    (data || {}).merge(
      company: company.name,
      username: user.username
    ).deep_symbolize_keys
  end

  def send_email?
    user.notification_on_collecting? &&
      (email_processed? || uploaded_pdf_processed?)
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
    ).tap(&:send_email)
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
