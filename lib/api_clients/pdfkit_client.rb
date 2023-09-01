# frozen_string_literal: true

module ApiClients
  class PdfkitClient
    include SimpleRestClient

    BASE_URL = 'https://pdfkit.poolpybot.fr/api'
    
    attr_reader :api_key

    def initialize(api_key:)
      @api_key = api_key
    end

    def pdf_to_text(pdf_url)
      response = post("#{BASE_URL}/pdf-to-text", { pdf_url: pdf_url }, http_headers)
      Rails.logger.debug ['[PdfkitClient][pdf_to_text]', response.code]
      response.code == '200' ? JSON.parse(response.body).with_indifferent_access : nil
    end

    def html_to_pdf(html_url)
      response = post("#{BASE_URL}/html-to-pdf", { html_url: html_url }, http_headers)
      Rails.logger.debug ['[PdfkitClient][html_to_pdf]', response.code]
      response.code == '200' ? StringIO.new(response.body) : nil
    end

    private

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
