# frozen_string_literal: true

require 'zip'
require 'csv'

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
      user = User.find(user_id)
      I18n.locale = user.locale # important to translate CSV headers for instance
      call(user: user, date: date)
    end

    private

    def invoices_for(user, date)
      user.company.invoices.optimized.processed.by_month(date)
    end

    def create_zipfile(user, date)
      invoices = invoices_for(user, date)

      open_zipfile do |zipfile|
        add_csv_to_zipfile(invoices, zipfile)
        add_all_pdfs_to_zipfile(invoices, zipfile)
      end
    end

    def add_csv_to_zipfile(invoices, zipfile)
      file = write_csvfile(invoices)
      zipfile.get_output_stream(csv_filename) do |output_entry_stream|
        output_entry_stream.write(File.read(file.path))
      end
    end

    def add_all_pdfs_to_zipfile(invoices, zipfile)
      # Improvement: use the Concurrent gem to download files in parallel.
      invoices.find_each do |invoice|
        add_pdf_to_zipfile(invoice, zipfile)
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

    def write_csvfile(invoices)
      Tempfile.new.tap do |tempfile|
        CSV.open(tempfile.path, 'w') do |csv|
          csv << invoice_csv_headers
          invoices.find_each do |invoice|
            csv << invoice_to_csv(invoice)
          end
        end
      end
    end

    def csv_filename
      'memo.csv'
    end

    def invoice_filename(invoice)
      name = invoice.invoice_supplier.normalized_name
      date = invoice.year_month
      "invoices-#{date}/#{name}-#{invoice.external_id}-#{date}.pdf"
    end

    def invoice_pdf_document_content(invoice)
      invoice.pdf_document.download
    end

    def invoice_csv_headers
      %w[supplier identifier date total_amount tax_amount pdf_filepath].map do |name|
        I18n.t(name, scope: 'services.invoices_export.csv_headers')
      end
    end

    def invoice_to_csv(invoice)
      [
        invoice.supplier&.name, invoice.external_id, invoice.date&.strftime('%Y-%m-%d'),
        invoice.total_amount, invoice.tax_amount,
        invoice_filename(invoice)
      ]
    end
  end
end
