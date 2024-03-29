# frozen_string_literal: true

module InvoiceCreatorServices
  module Concerns
    module MailInvoiceConcern
      def create_invoice_from_mail_body(user, mail)
        # call the AI to get the information about the invoice we need
        invoice_info = parse_invoice_information(user, mail)

        # ok, the AI wasn't able to parse correctly the invoice, no big deal, just let us know!
        return create_failed_invoice(user, mail, :parse_with_ai) unless invoice_info

        # detect that we haven't already processed the invoice (thru the identifier attribute)
        existing_invoice = user.company.invoices.find_by(external_id: invoice_info[:identifier])
        return existing_invoice if existing_invoice

        create_invoice_and_supplier(user, mail, invoice_info).tap do |invoice|
          attach_documents(invoice, mail)
        end
      end

      def create_invoice_from_pdf(user, pdf_attachment)
        pdf_invoice_creator.call(user: user, pdf: {
                                   io: StringIO.new(pdf_attachment.decoded),
                                   filename: pdf_attachment.filename,
                                   content_type: pdf_attachment.mime_type
                                 }, disable_notification: true)
      end

      def create_invoice_and_supplier(user, mail, invoice_info)
        supplier = find_or_create_invoice_supplier(user.company, invoice_info, mail.from_address)

        supplier.invoices.create(invoice_attributes(user, invoice_info))
      end

      def invoice_attributes(user, invoice_info)
        {
          company: user.company, user: user, status: :processing,
          external_id: invoice_info[:identifier],
          external_link: invoice_info[:link]
        }.merge(
          invoice_info.slice(:date, :total_amount, :tax_rate, :currency)
        )
      end

      def create_failed_invoice(user, mail, error)
        user.invoices.create!(
          company: user.company,
          external_id: mail.message_id,
          status: :failed,
          error: error
        )
      end

      def create_invoice_email(invoice, mail)
        invoice.create_invoice_email(
          subject: mail.original_subject || mail.subject.to_s,
          from: mail.from_address,
          name: mail.from_name,
          forwarded_at: mail.date
        )
      end

      def parse_invoice_information(user, mail)
        invoice_parser.call(
          text: mail.text_body,
          company_name: user.company.name,
          context: {
            email_subject: mail.original_subject || mail.subject.to_s
          }
        )
      end

      def attach_documents(invoice, mail)
        # first step: persist the HTML document in order for the PdfKit API to reach it
        persist_html_document(invoice, mail)

        # call our Pdfkit to generate the PDF out of the HTML doc
        attach_pdf_document(invoice, mail)

        # and we're done 👍
        invoice.processed!
      end

      def attach_pdf_document(invoice, _mail)
        pdf_io = html_to_pdf.call(
          url: invoice_document_url(invoice, :html)
        )

        invoice.pdf_document.attach(
          io: pdf_io, filename: 'invoice.pdf', content_type: 'application/pdf', identify: false
        )
        invoice.save
      end

      def persist_html_document(invoice, mail)
        invoice.html_document.attach(
          io: StringIO.new(get_html_body(invoice, mail)),
          filename: 'invoice.html', content_type: 'text/html', identify: false
        )
        invoice.save
      end

      def find_pdf_attachment(mail)
        mail.attachments.find do |attachment|
          attachment.mime_type == 'application/pdf'
        end
      end

      def get_html_body(invoice, mail)
        if invoice.external_link.present? && invoice.invoice_supplier.follow_link?
          html_client.call(url: invoice.external_link)
        end || mail.html_body
      end
    end
  end
end
