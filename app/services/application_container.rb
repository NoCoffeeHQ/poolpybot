# frozen_string_literal: true

class ApplicationContainer < ServiceOrchestrator::Container
  # API clients
  register :aleph_alpha_client do
    ApiClients::AlephAlphaClient.new(
      api_token: Rails.application.credentials.aleph_alpha.api_token
    )
  end

  register :openai_client do
    OpenAI::Client.new
  end

  # Business logic services
  register :onboarding, 'OnboardingService'
  register :smart_invoice_parser, 'AlephAlphaInvoiceParserService'
  register :brevo_ingress, 'BrevoIngressService'
end
