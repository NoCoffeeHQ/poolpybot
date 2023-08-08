# frozen_string_literal: true

module InvoiceCreatorServices
  class MailService < ApplicationService
    dependency :invoice_parser

    def call(mail:)
      user = find_user(mail)

      return if !user

      create_invoice(user, mail)
    end

    private

    def find_user(mail)
      User.find_by(uuid: mail.to.first.split('@').first)
    end

    def create_invoice(user, mail)
      # call the AI to get the information about the invoice we need 
      parsed_information = invoice_parser.call(text: mail.text_part.body)

      # ok, the AI wasn't able to parse correctly the invoice, no big deal, just let us know!
      return create_failed_invoice(user, mail, :mail_parsing) unless parsed_information

      # create both the supplier (if new) and the invoice
      find_or_create_invoice_supplier(user, parsed_information)
      .invoices
      .create(invoice_attributes(user, parsed_information))
    end

    def find_or_create_invoice_supplier(user, parsed_information)
      user.company.invoice_suppliers.find_or_create_by(name: parsed_information[:company_name])
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
  end
end