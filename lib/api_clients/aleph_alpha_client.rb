# frozen_string_literal: true

module ApiClients
  class AlephAlphaClient
    include SimpleRestClient

    BASE_URL = 'https://api.aleph-alpha.com'

    attr_reader :api_token

    def initialize(api_token:)
      @api_token = api_token
    end

    def complete(prompt)
      response = post("#{BASE_URL}/complete", build_body(prompt), http_headers)
      # TODO: deal with errors
      Rails.logger.debug [response.code, response.body]
      response.code == '200' ? JSON.parse(response.body).with_indifferent_access : nil
    end

    private

    def build_body(prompt)
      {
        model: 'luminous-extended-control',
        prompt: prompt,
        maximum_tokens: 128
      }
    end

    # rubocop:disable Style/StringHashKeys
    def http_headers
      {
        'Authorization' => "Bearer #{api_token}",
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    end
    # rubocop:enable Style/StringHashKeys
  end
end
