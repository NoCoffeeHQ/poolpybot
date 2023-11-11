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
      return original_text_body if forwarded? && original_text_body

      if multipart?
        # we assume that we'll get a text and html versions of the email
        text_part.body.encoded
      elsif sub_type == 'html'
        # at this point, we only have a HTML version of the email, let's try to get as much
        # information as we can (especially links)
        extract_text_from_html(body.decoded)
      else
        # text?
        body.decoded
      end
    end

    def html_body
      forwarded? ? original_html_body : body.decoded
    end

    private

    def extract_text_from_html(html)
      doc = Nokogiri::HTML(html)
      content = []
      doc.traverse { |node| visit_html_node(node, content) }
      content.join("\n")
    end

    def visit_html_node(node, memo)
      if node.text? && node.content.strip.length.positive?
        memo << node.content.strip
      elsif node.name == 'a' && node[:href]
        visit_html_link_node(node, memo)
      end
    end

    def visit_html_link_node(node, memo)
      # Here, you can customize how you want to represent a link and its text
      if memo.last == node.text.strip
        memo.last << " <#{node[:href]}>"
      else
        memo << "#{node.text.strip} <#{node[:href]}>"
      end
    end
  end
end
