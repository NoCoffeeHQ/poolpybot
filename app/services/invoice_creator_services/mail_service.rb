# frozen_string_literal: true

module InvoiceCreatorServices
  class MailService < ApplicationService

    def call(mail:)

    end

    private

    def find_user(mail)
      # Company.find_by(uuid: item[:To].first[:Address].split('@'))
    end
  end
end