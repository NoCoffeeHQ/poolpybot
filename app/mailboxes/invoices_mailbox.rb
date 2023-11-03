# frozen_string_literal: true

class InvoicesMailbox < ApplicationMailbox
  include BrevoConcern

  def process
    application_container.mail_invoice_creator.call(
      mail: ForwardedMail.new(mail)
    )
  end
end
