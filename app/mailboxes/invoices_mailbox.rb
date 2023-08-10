# frozen_string_literal: true

class InvoicesMailbox < ApplicationMailbox
  before_processing :decode_brevo_attachments

  def process
    application_container.mail_invoice_creator.call(mail: mail)
  end

  private

  def decode_brevo_attachments
    Mail.brevo_decode_attachments(mail, only_pdf: true)
  end

  def application_container
    @application_container ||= ApplicationContainer.new
  end
end
