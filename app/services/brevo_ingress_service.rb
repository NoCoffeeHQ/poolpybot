# frozen_string_literal: true

class BrevoIngressService < ApplicationService
  dependency :smart_invoice_parser

  def call(items:)
    items.each do |item|
      process_item(item)
    end
  end

  private

  def process_item(item)
    find_company(item)
    Rails.logger.debug extract_raw_text(item)
  end

  def find_company(item)
    Company.find_by(uuid: item[:To].first[:Address].split('@'))
  end

  def extract_raw_text(item)
    item[:RawTextBody].gsub(/^> /, '')
  end
end
