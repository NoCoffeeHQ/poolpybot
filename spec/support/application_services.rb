# frozen_string_literal: true

module ApplicationServicesHelper
  def build_application_container_mock
    ApplicationContainer.new.tap do |container|
      container.invoice_parser = instance_double('FakeInvoiceParser', call: true)
      container.html_to_pdf = instance_double('FakeHtmlToPdf', call: true)
      container.html_client = instance_double('HtmlClient', call: nil)
    end
  end
end

RSpec.configure do |config|
  config.include ApplicationServicesHelper
end
