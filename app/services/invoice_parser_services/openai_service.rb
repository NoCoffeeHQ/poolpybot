# frozen_string_literal: true

module InvoiceParserServices
  class OpenaiService < ApplicationService
    dependency :openai_client

    JSON_KEYS = %w[company_name identifier date total_amount tax_rate currency].sort.freeze

    def call(text:, company_name:)
      build_json(
        openai_client.completions(
          parameters: build_parameters(text, company_name)
        )
      )
    end

    private

    def build_parameters(text, company_name)
      {
        model: 'text-davinci-003',
        prompt: build_prompt(text, company_name),
        temperature: 0.0,
        max_tokens: 150,
        stop: '\n'
      }
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
      JSON.parse(response['choices'].map { |c| c['text'] }.join("\n")).with_indifferent_access
    end

    # rubocop:disable Metrics/MethodLength
    def build_prompt(text, company_name)
      <<~PROMPT
        As the owner of the "#{company_name}" company, I receive invoices by email from various suppliers and vendors. From the mail body, please generate a JSON object with only the following attributes:
        - company_name: Name of the company without the email address. The name can't be "#{company_name}" or similar to "#{company_name}".
        - identifier: The identifier of the invoice. If you don't find it, use the command number.
        - date: The date of the invoice date, in the "yyyy/mm/dd" date format.
        - total_amount: The total amount of the invoice as a float number, without the currency and in English format.
        - tax_rate: The VTA rate as a float number, null if not found.
        - currency: The currency in the ISO 4217 format.

        The mail body: """
        #{text}
        """
        The JSON object:
      PROMPT
        .strip
    end
    # rubocop:enable Metrics/MethodLength

    def build_legacy_prompt(text, company_name)
      <<~PROMPT
        I receive invoices by email from various companies. Please extract the following information from the provided email surrounded by backticks:

        ```
        #{text}
        ```

         From the provided email, you will extract ONLY the following information and present it in a VALID JSON format WITHOUT any backticks:
        - Company Name (without the email address and it can't be "#{company_name}" since it's my company. Name the attribute as "company_name")
        - Invoice Identifier (if you don't find it, use the command number. name the attribute as "identifier")
        - Invoice Date (in the date "yyyy/mm/dd" format and name the attribute as "date")
        - Total Amount of the Invoice (without the currency and in English format, it's a float number. Name the attribute as "total_amount")
        - TVA rate (if you don't find it, put null. name the attribute as "tax_rate", it's a float number)
        - Currency (not the ASCII symbol but the ISO 4217 code instead. Name the attribute as "currency")
      PROMPT
    end
  end
end
