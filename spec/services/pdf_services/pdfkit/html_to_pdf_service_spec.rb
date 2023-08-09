# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PdfServices::Pdfkit::HtmlToPdfService do
  let(:container) { ApplicationContainer.new }
  let(:client) { container.pdfkit_client }
  let(:instance) { described_class.new(pdfkit_client: client) }

  subject { instance.call(url: url) }

  describe 'Given an existing PDF url' do
    let(:url) { 'https://poolpybot-pdfkit.osc-fr1.scalingo.io/samples/invoice.html' }

    it 'converts the HTML page into a PDF' do
      expect(subject.size).to eq 64202
    end
  end
end