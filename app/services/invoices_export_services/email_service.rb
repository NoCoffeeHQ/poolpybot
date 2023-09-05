# frozen_string_literal: true

require 'zip'

module InvoicesExportServices
  class EmailService < ApplicationService
    def call(user:, date:)
      return false if invoices_for(user, date).empty?

      zipfile = create_zipfile(user, date)

      UserMailer.invoices_export(user, date, zipfile).deliver_now

      zipfile
    end

    def call_from_job(user_id:, date:)
      logger.debug "🗄️ #{user_id} / #{date}"
      call(user: User.find(user_id), date: date)
    end

    private

    def invoices_for(user, date)
      user.company.invoices.optimized.processed.by_month(date)
    end

    def create_zipfile(user, date)
      open_zipfile do |zipfile|
        # Improvement: use the Concurrent gem to download files in parallel.
        invoices_for(user, date).find_each do |invoice|
          add_pdf_to_zipfile(invoice, zipfile)
        end
      end
    end

    def add_pdf_to_zipfile(invoice, zipfile)
      zipfile.get_output_stream(invoice_filename(invoice)) do |output_entry_stream|
        output_entry_stream.write(invoice_pdf_document_content(invoice))
      end
    end

    def open_zipfile(&block)
      Tempfile.new.tap do |tempfile|
        Zip::File.open(tempfile.path, create: true, &block)
      end
    end

    def invoice_filename(invoice)
      name = invoice.invoice_supplier.normalized_name
      date = invoice.date.strftime('%Y-%m')
      "invoices-#{date}/#{name}-#{invoice.external_id}-#{date}.pdf"
    end

    def invoice_pdf_document_content(invoice)
      invoice.pdf_document.download
    end
  end
end
