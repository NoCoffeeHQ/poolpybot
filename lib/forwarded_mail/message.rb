# frozen_string_literal: true

module ForwardedMail
  class Message < SimpleDelegator
    attr_reader :original_subject, :original_from, :original_text_body, :original_html_body

    def initialize(mail)
      super
      parsed_info = Parser.call(mail: mail)
      @original_subject = parsed_info[:subject]
      @original_from = parsed_info[:from]
      @original_text_body = parsed_info[:text_body]
      @original_html_body = parsed_info[:html_body]
    end

    def forwarded?
      original_subject.present?
    end

    def from_address
      forwarded? && original_from ? original_from[:address] : self[:from].address
    end

    def from_name
      forwarded? && original_from ? original_from[:name] : self[:from].display_names.first
    end

    def text_body
      forwarded? ? original_text_body : text_part.body.encoded
    end
  end
end
