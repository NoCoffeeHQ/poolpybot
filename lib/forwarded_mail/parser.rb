# frozen_string_literal: true

# A big thanks to Crisp for coding the Javascript initial version
# https://github.com/crisp-oss/email-forward-parser/blob/master/lib/parser.js (MIT License)
#
# This Ruby version is way simpler than the Crisp one.
#
module ForwardedMail
  class Parser
    include Regexps

    attr_reader :mail, :raw_body, :html_body

    def initialize(mail:)
      @mail = mail
      @raw_body = extract_original_body(mail.text_part.body.decoded.to_s.force_encoding('UTF-8'))
      @html_body = mail.html_part.body.to_s
    end

    def call
      {
        subject: parse_subject,
        from: parse_from,
        text_body: parse_original_text_body,
        html_body: parse_original_html_body
      }
    end

    def self.call(mail:)
      new(mail: mail).call
    end

    private

    def parse_subject
      matches = loop_match(SUBJECT_REGEXPS, mail.subject)
      matches ? matches[1].strip : nil
    end

    def parse_from
      # First method: extract the author via the From part
      # (Apple Mail, Gmail, Outlook Live / 365, New Outlook 2019, Thunderbird)
      parse_mailbox ||
        # Second method: extract the author via the From part,
        # using lax regexes (Yahoo Mail)
        lax_parse_mailbox ||
        # Unknown from
        { name: nil, address: nil }
    end

    def parse_mailbox
      matches = loop_match(FROM_REGEXPS, raw_body)

      return nil unless matches&.size&.positive?

      if (mailbox_matches = loop_match(MAILBOX_REGEXP, matches[2]))
        prepare_mailbox(
          mailbox_matches.size == 3 ? mailbox_matches[1] : nil,
          mailbox_matches[2]
        )
      else
        prepare_mailbox(nil, matches[2])
      end
    end

    def lax_parse_mailbox
      matches = loop_match(FROM_LAX_REGEXPS, raw_body)

      return nil unless matches && matches.size > 1

      prepare_mailbox(matches[2], matches[3])
    end

    def prepare_mailbox(name, address)
      {
        # Some clients fill the name with the address ("bessie.berry@acme.com <bessie.berry@acme.com>")
        name: name != address ? name&.strip : nil,
        address: address.strip
      }
    end

    def extract_original_body(body)
      body
        .gsub(BYTE_ORDER_MARK_REGEXP, '') # Remove Byte Order Mark
        .gsub(QUOTE_LINE_BREAK_REGEXP, '') # Remove ">" at the beginning of each line, while keeping line breaks
        .gsub(QUOTE_REGEXP, '') # Remove ">" at the beginning of other lines
        .gsub(FOUR_SPACE_REGEXP, '') # Remove "    " at the beginning of lines
    end

    def parse_original_text_body
      loop_gsub(
        SEPARATOR_REGEXPS + ORIGINAL_SUBJECT_REGEXPS + ORIGINAL_FROM_REGEXPS +
        ORIGINAL_TO_REGEXPS + ORIGINAL_DATE_REGEXPS + ORIGINAL_CC_REGEXPS + ORIGINAL_REPLY_TO_REGEXPS,
        raw_body
      ).strip
    end

    def parse_original_html_body
      case html_body
      when /<br class="Apple-interchange-newline">/
        remove_apple_header(html_body)
      when /<div class="gmail_quote">/
        remove_gmail_header(html_body)
      else
        html_body
      end
    end

    def remove_apple_header(html)
      transform_html(html) do |html_doc|
        html_doc.css('blockquote[type="cite"] > :nth-child(-n+6)').each(&:remove)
      end
    end

    def remove_gmail_header(html)
      transform_html(html) do |html_doc|
        html_doc.css('div.gmail_attr').each(&:remove)
      end
    end

    def transform_html(html)
      html_doc = Nokogiri::HTML(html)
      yield html_doc
      html_doc.to_html
    end

    def loop_gsub(regexps, text, replacement = '')
      regexps.reduce(text) { |memo, regexp| memo.gsub(regexp, replacement) }
    end

    def loop_match(regexps, text)
      regexps.each do |regexp|
        matches = text.match(regexp)

        # pp [regexp, text.size, matches&.size]

        return matches if matches && matches.size > 1
      end
      nil
    end
  end
end
