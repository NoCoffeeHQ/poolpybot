# frozen_string_literal: true

class OpenaiInvoiceParserService < ApplicationService
  dependency :openai_client

  JSON_KEYS = %w[company_name date total_amount tax_rate currency].sort.freeze

  def call(text:)
    build_json(
      openai_client.completions(
        parameters: build_parameters(text)
      )
    )
  end

  private

  def build_parameters(text)
    {
      model: 'text-davinci-003',
      prompt: build_prompt(text),
      temperature: 0.1,
      max_tokens: 150,
      stop: '\n'
    }
  end

  def build_json(response)
    JSON.parse(response['choices'].map { |c| c['text'] }.join("\n")).with_indifferent_access.tap do |json|
      raise 'Wrong JSON keys' unless json.keys.sort == JSON_KEYS
    end
  rescue StandardError => e
    Rails.logger.warn "🚨 Unable to get a valid response from Openai, error=#{e.message}"
    false
  end

  def build_prompt(text)
    <<~PROMPT
            I receive invoices by email from various companies. Please extract the following information from the provided email surrounded by backticks:

            ```
            #{text}
            ```

            From the provided email, you will extract the following information and present it in a valid JSON format without the backticks:
            - Company Name (without the email address)
            - Invoice Date (in the date "yyyy/mm/dd" format and name the attribute as "date")
            - Total Amount of the Invoice (without the currency and in English format, it's a float number)
            - TVA rate (if you don't found it, put null. name the attribute as "tax_rate", it's a float number
      )
            - Currency (not the ASCII symbol but the ISO 4217 code instead)
    PROMPT
  end
end
