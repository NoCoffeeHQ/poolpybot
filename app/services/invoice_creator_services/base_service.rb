# frozen_string_literal: true

module InvoiceCreatorServices
  class BaseService < ApplicationService
    private

    def find_or_create_invoice_supplier(company, invoice_info, email = nil)
      supplier = company.invoice_suppliers.similar_to(invoice_info[:company_name]).first

      if supplier
        supplier.update(emails: (supplier.emails << email).uniq)
      else
        company.invoice_suppliers.create(name: invoice_info[:company_name], emails: [email])
      end
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
  end

  class FailInvoiceError < StandardError
    attr_reader :invoice

    def initialize(invoice)
      @invoice = invoice
      super
    end
  end
end
