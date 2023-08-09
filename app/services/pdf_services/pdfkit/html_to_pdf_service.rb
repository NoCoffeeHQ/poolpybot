# frozen_string_literal: true

module PdfServices
  module Pdfkit
    class HtmlToPdfService < ApplicationService
      dependency :pdfkit_client

      def call(url:)
        pdfkit_client.html_to_pdf(url)
      end
    end
  end
end