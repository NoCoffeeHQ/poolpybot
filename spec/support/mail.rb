# frozen_string_literal: true

module MailLoaderHelper
  def fetch_mail(email_type)
    ForwardedMail.new(
      Mail.read_from_string(
        File.read(
          Rails.root.join("spec/fixtures/files/mails/#{email_type}.eml").to_s
        )
      )
    )
  end
end

RSpec.configure do |config|
  config.include MailLoaderHelper
end
