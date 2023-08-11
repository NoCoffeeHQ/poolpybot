# frozen_string_literal: true

module PdfServices
  module Pdfkit
    class PdfToTextService < ApplicationService
      dependency :pdfkit_client

      def call(url:)
        response = pdfkit_client.pdf_to_text(url)
        response ? clean(response[:text]) : nil
      end

      private 

      def clean(text)
        text.gsub(/\x0A[^\w]+$/, '').strip
      end
    end
  end
end
