# frozen_string_literal: true

module InvoiceCreatorServices
  class PdfService < ApplicationService
    dependencies :invoice_parser, :pdf_to_text

    # PDF is an attachable object (see ActiveStorage)
    def call(user:, pdf:)
      invoice = create_basic_invoice(user, pdf)

      # extract the text from the PDF
      text = extract_text(invoice)

      # call the AI to get the information about the invoice we need
      invoice_info = parse_text(invoice, text)

      # set the supplier, change the status and set the invoice information to the invoice
      complete_invoice(invoice, invoice_info)
    rescue FailInvoiceError => e
      e.invoice
    end

    private

    def extract_text(invoice)
      pdf_to_text.call(url: invoice_document_url(invoice, :pdf)).tap do |text|
        raise_error(invoice, :extract_text) if text.blank?
      end
    end

    def parse_text(invoice, text)
      invoice_parser.call(text: text, company_name: invoice.company.name).tap do |info|
        raise_error(invoice, :parse_with_ai) if info.blank?
      end
    end

    def check_invoice_uniqueness(invoice, invoice_info)
      raise_error(invoice, :missing_identifier) if invoice_info[:identifier].blank?

      return unless (original = invoice.company.invoices.find_by(external_id: invoice_info[:identifier]))

      raise_error(invoice, :duplicated, { duplicate_of: original })
    end

    def complete_invoice(invoice, invoice_info)
      check_invoice_uniqueness(invoice, invoice_info)

      invoice.update(
        {
          status: :processed,
          invoice_supplier: find_or_create_invoice_supplier(invoice.company, invoice_info),
          external_id: invoice_info[:identifier]
        }.merge(invoice_info.slice(:date, :total_amount, :tax_rate, :currency))
      )

      invoice
    end

    def find_or_create_invoice_supplier(company, invoice_info)
      company.invoice_suppliers.find_or_create_by(name: invoice_info[:company_name])
    end

    def create_basic_invoice(user, pdf)
      user.invoices.create(company: user.company, status: :created, pdf_document: pdf)
    end

    def invoice_document_url(invoice, type)
      Rails.application.routes.url_helpers.invoice_document_url(
        SimpleEncryption.encrypt("#{invoice.id}-#{5.minutes.after.to_i}"), format: type
      )
    end

    def raise_error(invoice, error, attributes = {})
      invoice.update({ status: :failed, error: error }.merge(attributes))
      raise FailInvoiceError, invoice
    end

    class FailInvoiceError < StandardError
      attr_reader :invoice

      def initialize(invoice)
        @invoice = invoice
        super
      end
    end
  end
end
