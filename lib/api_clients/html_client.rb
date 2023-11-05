# frozen_string_literal: true

module ApiClients
  class HtmlClient
    include SimpleRestClient

    def call(url:)
      response = get(url)
      response.code == '200' ? response.body : nil
    end
  end
end
