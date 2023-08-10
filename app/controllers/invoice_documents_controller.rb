# frozen_string_literal: true

class InvoiceDocumentsController < ApplicationController
  before_action :fetch_invoice_id

  def show
    invoice = Invoice.find(@invoice_id)
    respond_to do |format|
      format.html { render html: invoice.html_document.download.html_safe }
      format.pdf { render pdf: invoice.pdf_document.download }
    end
  end

  private

  def fetch_invoice_id
    @invoice_id, time_in_seconds = SimpleEncryption.decrypt(params[:id]).split('-')
    head :unauthorized if Time.now > Time.at(time_in_seconds.to_i)
  end
end
