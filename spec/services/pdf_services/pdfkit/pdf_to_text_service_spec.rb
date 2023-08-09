# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PdfServices::Pdfkit::PdfToTextService do
  let(:container) { ApplicationContainer.new }
  let(:client) { container.pdfkit_client }
  let(:instance) { described_class.new(pdfkit_client: client) }

  subject { instance.call(url: url) }

  describe 'Given an existing PDF url' do
    let(:url) { 'https://poolpybot-pdfkit.osc-fr1.scalingo.io/samples/invoice.pdf' }

    it 'extracts the text out of the PDF' do
      is_expected.to match /Invoice: #51105001/
    end
  end
end