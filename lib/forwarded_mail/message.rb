# frozen_string_literal: true

module ForwardedMail
  class Message < SimpleDelegator
    attr_reader :original_subject, :original_from, :original_html_body

    def initialize(mail)
      super
      parsed_info = Parser.call(mail: mail)
      @original_subject = parsed_info[:subject]
      @original_from = parsed_info[:from]
      @original_html_body = parsed_info[:html_body]
    end

    def forwarded?
      original_subject.present?
    end

    def from_address
      forwarded? && original_from ? original_from[:address] : from.addresses.first
    end

    def from_name
      forwarded? && original_from ? original_from[:name] : from.display_names.first
    end
  end
end
