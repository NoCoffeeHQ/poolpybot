# frozen_string_literal: true

module ApiClients
  class OpenaiClient
    include SimpleRestClient

    BASE_URL = 'https://api.openai.com'

    attr_reader :api_key

    def initialize(api_key:)
      @api_key = api_key
    end

    def complete(messages:, model: nil)
      response = post("#{BASE_URL}/v1/chat/completions", build_body(messages, model), http_headers)
      # TODO: deal with errors
      Rails.logger.debug [response.code, response.body]
      response.code == '200' ? JSON.parse(response.body).with_indifferent_access : nil
    end

    private

    def build_body(messages, model = nil)
      {
        model: model || 'gpt-3.5-turbo',
        messages: messages,
        temperature: 0,
        max_tokens: 512,
        top_p: 1,
        frequency_penalty: 0,
        presence_penalty: 0
      }
    end

    # rubocop:disable Style/StringHashKeys
    def http_headers
      {
        'Authorization' => "Bearer #{api_key}",
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    end
    # rubocop:enable Style/StringHashKeys
  end
end
