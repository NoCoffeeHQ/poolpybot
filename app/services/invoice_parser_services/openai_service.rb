# frozen_string_literal: true

module InvoiceParserServices
  class OpenaiService < ApplicationService
    dependency :openai_client

    JSON_KEYS = %w[company_name identifier date total_amount tax_rate currency link].sort.freeze

    def call(text:, company_name:, context: {})
      build_json(
        openai_client.complete(
          messages: build_messages(text, company_name, context)
        )
      )
    end

    private

    def build_messages(text, company_name, context)
      [
        { role: 'system', content: 'You are a bot collecting invoice information.' },
        { role: 'user', content: build_instructions(company_name) },
        context[:email_subject] ? { role: 'user', content: 'Here is the email subject' } : nil,
        context[:email_subject] ? { role: 'user', content: context[:email_subject] } : nil,
        { role: 'user', content: 'Here is the email body' },
        { role: 'user', content: text.to_s.gsub(/[^[:print:]]/, '').split("\n").map(&:strip).join("\n") }
      ].compact
    end

    def build_json(response)
      raise 'No valid response' if response['choices'].blank?

      core_build_json(response).tap do |json|
        raise 'Wrong JSON keys' unless json.keys.sort == JSON_KEYS
      end
    rescue StandardError => e
      Rails.logger.warn "🚨 Unable to get a valid response from Openai, error=#{e.message}"
      false
    end

    def core_build_json(response)
      JSON.parse(
        response['choices'].first.dig('message', 'content').strip
      ).with_indifferent_access
    end

    def build_instructions(company_name)
      <<~PROMPT
        As the owner of the "#{company_name}" company, I receive invoices by email from various suppliers and vendors. From the mail body, please generate a JSON object with only the following attributes:
        - company_name: Name of the company without the email address. The name can't be "#{company_name}" or similar to "#{company_name}".
        - identifier: The identifier of the invoice. If you don't find it, use the command number.
        - date: The date of the invoice date, in the "yyyy/mm/dd" date format.
        - total_amount: The total amount of the invoice as a float number, without the currency and in English format.
        - tax_rate: The VTA rate as a float number, null if not found.
        - currency: The currency in the ISO 4217 format.
        - link: The url to view the invoice, null if not found or if the url is to report a problem or to view the payment receipt.
      PROMPT
        .strip
    end
  end
end
