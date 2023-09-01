# frozen_string_literal: true

module MailLoaderHelper
  def mail(email_type)
    ForwardedMail.new(
      Mail.read_from_string(
        File.read(
          Rails.root.join("spec/fixtures/mails/#{email_type}.txt").to_s
        )
      )
    )
  end
end

RSpec.configure do |config|
  config.include MailLoaderHelper
end
