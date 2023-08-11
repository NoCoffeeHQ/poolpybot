# frozen_string_literal: true

module InvoiceCreatorServices
  class MailService < InvoiceCreatorServices::BaseService
    dependencies :invoice_parser, :pdf_invoice_creator, :html_to_pdf

    def call(mail:)
      user = find_user(mail)

      return unless user

      if (pdf_document = find_pdf_attachment(mail))
        create_invoice_from_pdf(user, pdf_document)
      else
        create_invoice_from_mail(user, mail)
      end
    end

    private

    def find_user(mail)
      User.find_by(uuid: mail.to.first.split('@').first)
    end

    def create_invoice_from_mail(user, mail)
      # call the AI to get the information about the invoice we need
      invoice_info = invoice_parser.call(text: mail.text_part.body, company_name: user.company.name)

      # ok, the AI wasn't able to parse correctly the invoice, no big deal, just let us know!
      return create_failed_invoice(user, mail, :parse_with_ai) unless invoice_info

      # detect that we haven't already processed the invoice (thru the identifier attribute)
      existing_invoice = user.company.invoices.find_by(external_id: invoice_info[:identifier])
      return existing_invoice if existing_invoice

      create_invoice(user, mail, invoice_info).tap do |invoice|
        attach_documents(invoice, mail)
      end
    end

    def create_invoice(user, mail, invoice_info)
      # in order to know which email addresses are important for our customer's invoicing
      # and so to make smart mailbox filters, we need to extract those emails from the Forwarded mail.
      email = mail.text_part.body.to_s[/^From: .*<(.*?)>\s*$/, 1]

      supplier = find_or_create_invoice_supplier(user.company, invoice_info, email)

      supplier.invoices.create(invoice_attributes(user, invoice_info))
    end

    def invoice_attributes(user, invoice_info)
      {
        company: user.company, user: user, status: :processing, external_id: invoice_info[:identifier]
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
        io: StringIO.new(ForwardedMailSanitizer.call(html: mail.html_part.body.to_s)),
        filename: 'invoice.html', content_type: 'text/html', identify: false
      )
      invoice.save
    end

    def find_pdf_attachment(mail)
      mail.attachments.find do |attachment|
        attachment.content_type == 'application/pdf'
      end
    end

    def create_invoice_from_pdf(user, pdf_attachment)
      pdf_invoice_creator.call(user: user, pdf: {
                                 io: StringIO.new(pdf_attachment.decoded),
                                 filename: pdf_attachment.filename,
                                 content_type: pdf_attachment.content_type
                               })
    end
  end
end
