# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('NO_REPLY_EMAIL_ADDRESS', 'from@example.com')
  layout 'mailer'
end
