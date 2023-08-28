# frozen_string_literal: true

class ApplicationContainer < ServiceOrchestrator::Container
  # API clients
  register(:aleph_alpha_client) { ApiClients::AlephAlphaClient.new(api_token: credentials.aleph_alpha.api_token) }
  register(:openai_client) { ApiClients::OpenaiClient.new(api_key: credentials.openai.api_key) }
  register(:pdfkit_client) { ApiClients::PdfkitClient.new(api_key: credentials.pdfkit.api_key) }

  # PDF services
  register :pdf_to_text, 'PdfServices::Pdfkit::PdfToTextService'
  register :html_to_pdf, 'PdfServices::Pdfkit::HtmlToPdfService'

  # Business logic services
  register :onboarding, 'OnboardingService'
  register :invoice_parser, 'InvoiceParserServices::OpenaiService'
  register :mail_invoice_creator, 'InvoiceCreatorServices::MailService'
  register :pdf_invoice_creator, 'InvoiceCreatorServices::PdfService'
  register :pdf_retry_invoice_creator, 'InvoiceCreatorServices::PdfRetryService'

  private

  def credentials
    Rails.application.credentials
  end
end
