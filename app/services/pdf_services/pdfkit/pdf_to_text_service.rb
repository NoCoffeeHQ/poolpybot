# frozen_string_literal: true

module PdfServices
  module Pdfkit
    class PdfToTextService < ApplicationService
      dependency :pdfkit_client

      def call(url:)
        response = pdfkit_client.pdf_to_text(url)
        response ? response[:text] : nil
      end
    end
  end
end
