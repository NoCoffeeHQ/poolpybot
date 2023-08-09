# frozen_string_literal: true

module InvoiceCreatorServices
  class MailService < ApplicationService
    dependencies :invoice_parser, :html_to_pdf

    def call(mail:)
      user = find_user(mail)

      return if !user

      # TODO: test if the mail has a PDF attached to it
      create_invoice_from_mail(user, mail)
    end

    private

    def find_user(mail)
      User.find_by(uuid: mail.to.first.split('@').first)
    end

    def create_invoice_from_mail(user, mail)
      # call the AI to get the information about the invoice we need 
      parsed_information = invoice_parser.call(text: mail.text_part.body)

      # ok, the AI wasn't able to parse correctly the invoice, no big deal, just let us know!
      return create_failed_invoice(user, mail, :mail_parsing) unless parsed_information

      # detect that we haven't already processed the invoice (thru the identifier attribute)
      existing_invoice = user.company.invoices.find_by(external_id: parsed_information[:identifier])
      return existing_invoice if existing_invoice

      create_invoice(user, parsed_information).tap do |invoice|
        attach_documents(invoice, mail)
      end
    end

    def find_or_create_invoice_supplier(user, parsed_information)
      user.company.invoice_suppliers.find_or_create_by(name: parsed_information[:company_name])
    end

    def create_invoice(user, parsed_information)
      # create both the supplier (if new) and the invoice
      find_or_create_invoice_supplier(user, parsed_information)
      .invoices
      .create(invoice_attributes(user, parsed_information))
    end

    def invoice_attributes(user, parsed_information) 
      { 
        company: user.company, user: user, status: :processed, external_id: parsed_information[:identifier]
      }.merge(
        parsed_information.slice(:date, :total_amount, :tax_rate, :currency)
      )
    end

    def create_failed_invoice(user, mail, error)
      user.company.invoices.create(
        external_id: mail.message_id,
        status: :failed,
        error: error
      )
    end

    def attach_documents(invoice, mail)
      # first step: persist the HTML document in order for the PdfKit API to reach it
      persist_html_document(invoice, mail)

      # call our Pdfkit to generate the PDF out of the HTML doc
      attach_pdf_document(invoice, mail)
    end

    def attach_pdf_document(invoice, mail)
      pdf_io = html_to_pdf.call(
        url: invoice.html_document.url(expires_in: 5.minutes)
      )
       
      invoice.pdf_document.attach(
        io: pdf_io, filename: 'invoice.pdf', content_type: 'application/pdf', identify: false
      )
      invoice.save
    end

    def persist_html_document(invoice, mail)
      invoice.html_document.attach(
        io: StringIO.new(ForwardedMailSanitizer.call(html: mail.html_part.body.to_s)),
        filename: 'invoice.html', content_type: 'text/html', identify: false
      )
      invoice.save
    end

    def find_pdf_attachment(mail)
      raise 'TODO 2'
      # mail.attachments.each do |attachment|

      # end
    end
  end
end