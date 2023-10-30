# frozen_string_literal: true

module InvoiceCreatorServices
  class MailService < InvoiceCreatorServices::BaseService
    include Concerns::MailInvoiceConcern

    dependencies :invoice_parser, :pdf_invoice_creator, :html_to_pdf

    def call(mail:)
      user = find_user(mail)

      return unless user

      create_invoice(user, mail).tap do |invoice|
        create_invoice_email(invoice, mail) unless invoice.invoice_email

        notify(user, mail, invoice)
      end
    end

    private

    def find_user(mail)
      User.find_by(uuid: mail.to.first.split('@').first)
    end

    def create_invoice(user, mail)
      if (pdf_document = find_pdf_attachment(mail))
        create_invoice_from_pdf(user, pdf_document)
      else
        create_invoice_from_mail_body(user, mail)
      end
    end

    def notify(user, mail, invoice)
      success = invoice.none_error?
      event = success ? :email_processed : :email_not_processed
      Notification.trigger(user: user, event: event, data: {
                             subject: mail.original_subject || mail.subject.to_s,
                             from: mail.from.to_s,
                             invoice_id: invoice.id
                           })
    end
  end
end
