# frozen_string_literal: true

module InvoiceCreatorServices
  class PdfService < InvoiceCreatorServices::BaseService
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
    rescue InvoiceCreatorServices::FailInvoiceError => e
      e.invoice
    end

    def call_from_job(user_id:, pdf_signed_id:)
      logger.debug "🚨 #{user_id} / #{pdf_signed_id}"
      call(user: User.find(user_id), pdf: pdf_signed_id)
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

    def create_basic_invoice(user, pdf)
      user.invoices.create(company: user.company, status: :created, pdf_document: pdf)
    end
  end
end
