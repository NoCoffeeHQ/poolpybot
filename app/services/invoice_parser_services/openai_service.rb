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
        temperature: 0.01,
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

    def build_prompt(text, company_name)
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
