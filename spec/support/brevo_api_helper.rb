# frozen_string_literal: true

module BrevoApiHelper
  def brevo_items(email_type)
    JSON.parse(
      File.read(
        Rails.root.join("spec/fixtures/brevo/#{email_type}_invoice.json").to_s
      )
    ).with_indifferent_access[:items]
  end
end
