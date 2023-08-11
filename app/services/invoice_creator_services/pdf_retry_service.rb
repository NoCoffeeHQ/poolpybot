# frozen_string_literal: true

module InvoiceCreatorServices
  class PdfRetryService < InvoiceCreatorServices::PdfService
    def call(invoice:)
      # extract the text from the PDF
      text = extract_text(invoice)

      # call the AI to get the information about the invoice we need
      invoice_info = parse_text(invoice, text)

      # set the supplier, change the status and set the invoice information to the invoice
      complete_invoice(invoice, invoice_info)
    rescue FailInvoiceError => e
      e.invoice
    end
  end
end
