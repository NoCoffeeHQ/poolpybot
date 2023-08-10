# frozen_string_literal: true

class InvoiceDocumentsController < ApplicationController
  before_action :fetch_invoice_id

  def show
    invoice = Invoice.find(@invoice_id)
    respond_to do |format|
      format.html { render plain: invoice.html_document.download }
      format.pdf { render plain: invoice.pdf_document.download }
    end
  end

  private

  def fetch_invoice_id
    @invoice_id, time_in_seconds = SimpleEncryption.decrypt(params[:id]).split('-')
    head :unauthorized if Time.zone.now > Time.zone.at(time_in_seconds.to_i)
  end
end
