# frozen_string_literal: true

class GmailForwardingCodeMailbox < ApplicationMailbox
  before_processing :ensure_receiver_is_a_user

  def process
    forward_to(fetch_user.email)
  end

  private

  def ensure_receiver_is_a_user
    bounced! unless fetch_user
  end

  def fetch_user
    @fetch_user ||= User.find_by(uuid: mail.to.first.split('@').first)
  end

  def forward_to(email)
    mail.to = email
    mail.from = ENV.fetch('NO_REPLY_EMAIL_ADDRESS', 'from@example.com')
    ActionMailer::Base.wrap_delivery_behavior(mail)
    mail.deliver
  end
end