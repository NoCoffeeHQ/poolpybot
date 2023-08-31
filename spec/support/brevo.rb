# frozen_string_literal: true

module BrevoApiHelper
  def brevo_items(email_type)
    JSON.parse(
      File.read(
        Rails.root.join("spec/fixtures/brevo/#{email_type}_invoice.json").to_s
      )
    ).with_indifferent_access[:items]
  end

  def brevo_mails(email_type)
    brevo_items(email_type).map do |item|
      ForwardedMail.new(
        Mail.from_brevo(item)
      )
    end
  end
end

RSpec.configure do |config|
  config.include BrevoApiHelper
end
