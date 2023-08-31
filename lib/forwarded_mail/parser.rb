# A big thanks to Crisp for coding the Javascript initial version
# https://github.com/crisp-oss/email-forward-parser/blob/master/lib/parser.js (MIT License)
#
# This Ruby version is way simpler than the Crisp one.
#
module ForwardedMail
  class Parser

    attr_reader :mail, :raw_body, :html_body

    def initialize(mail:)
      @mail = mail
      @raw_body = extract_original_body(mail.body.encoded)
      @html_body = mail.html_part.body.to_s
    end

    def call
      {
        subject: parse_subject,
        from: parse_from,
        text_body: raw_body,
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
      # First method: extract the author via the From part (Apple Mail, Gmail, Outlook Live / 365, New Outlook 2019, Thunderbird)
      parse_mailbox ||
      # Second method: extract the author via the From part, using lax regexes (Yahoo Mail)
      lax_parse_mailbox ||
      # Unknown from
      { name: nil, address: nil }
    end

    def parse_mailbox
      matches = loop_match(FROM_REGEXPS, raw_body)

      return nil unless matches && matches.size > 0

      mailbox_matches = loop_match(MAILBOX_REGEXP, matches[2])

      mailbox_matches ? prepare_mailbox(
        mailbox_matches.size == 3 ? mailbox_matches[1] : nil,
        mailbox_matches[2]
      ) : matches[2]
    end

    def lax_parse_mailbox
      matches = loop_match(FROM_LAX_REGEXPS, raw_body)

      return nil unless matches && matches.size > 1

      prepare_mailbox(matches[2], matches[3])
    end

    def prepare_mailbox(name, address)
      {
        name: name != address ? name.strip : nil, # Some clients fill the name with the address ("bessie.berry@acme.com <bessie.berry@acme.com>")
        address: address
      }
    end

    def extract_original_body(body)
      body
      .gsub(BYTE_ORDER_MARK_REGEXP, '') # Remove Byte Order Mark
      .gsub(QUOTE_LINE_BREAK_REGEXP, '') # Remove ">" at the beginning of each line, while keeping line breaks
      .gsub(QUOTE_REGEXP, '') # Remove ">" at the beginning of other lines
      .gsub(FOUR_SPACE_REGEXP, '') # Remove "    " at the beginning of lines
    end

    def loop_match(regexps, text)
      regexps.each do |regexp|
        matches = text.match(regexp)

        # pp [regexp, text.size, matches&.size]

        return matches if matches && matches.size > 1
      end
      nil
    end

    def parse_original_html_body
      case html_body
      when /<br class="Apple-interchange-newline">/
        remove_apple_header(html_body)
      when /<div class="gmail_quote">/
        remove_gmail_header(html_body)
      else
        html
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

    ## REGEXPS ##

    BYTE_ORDER_MARK_REGEXP = /\uFEFF/m # Outlook 2019
    QUOTE_LINE_BREAK_REGEXP = /^(>+)\s?$/m # Apple Mail, Missive
    QUOTE_REGEXP = /^(>+)\s?/m # Apple Mail
    FOUR_SPACE_REGEXP = /^(\ {4})\s?/m # Outlook 2019
    
    SUBJECT_REGEXPS = [
      /^Fw:(.*)/m, # Outlook Live / 365 (cs, en, hr, hu, sk), Yahoo Mail (all locales)
      /^VS:(.*)/m, # Outlook Live / 365 (da), New Outlook 2019 (da)
      /^WG:(.*)/m, # Outlook Live / 365 (de), New Outlook 2019 (de)
      /^RV:(.*)/m, # Outlook Live / 365 (es), New Outlook 2019 (es)
      /^TR:(.*)/m, # Outlook Live / 365 (fr), New Outlook 2019 (fr)
      /^I:(.*)/m, # Outlook Live / 365 (it), New Outlook 2019 (it)
      /^FW:(.*)/m, # Outlook Live / 365 (nl, pt), New Outlook 2019 (cs, en, hu, nl, pt, ru, sk), Outlook 2019 (all locales)
      /^Vs:(.*)/m, # Outlook Live / 365 (no)
      /^PD:(.*)/m, # Outlook Live / 365 (pl), New Outlook 2019 (pl)
      /^ENC:(.*)/m, # Outlook Live / 365 (pt-br), New Outlook 2019 (pt-br)
      /^Redir.:(.*)/m, # Outlook Live / 365 (ro)
      /^VB:(.*)/m, # Outlook Live / 365 (sv), New Outlook 2019 (sv)
      /^VL:(.*)/m, # New Outlook 2019 (fi)
      /^Videresend:(.*)/m, # New Outlook 2019 (no)
      /^İLT:(.*)/m, # New Outlook 2019 (tr)
      /^Fwd:(.*)/m # Gmail (all locales), Thunderbird (all locales), Missive (en)
    ]

    FROM_REGEXPS = [
      /^(\*?\s*From\s?:\*?(.+))$/, # Apple Mail (en), Outlook Live / 365 (all locales), New Outlook 2019 (en), Thunderbird (da, en), Missive (en), HubSpot (en)
      /^(\s*Od\s?:(.+))$/, # Apple Mail (cs, pl, sk), Gmail (cs, pl, sk), New Outlook 2019 (cs, pl, sk), Thunderbird (cs, sk), HubSpot (pl)
      /^(\s*Fra\s?:(.+))$/, # Apple Mail (da, no), Gmail (da, no), New Outlook 2019 (da), Thunderbird (no)
      /^(\s*Von\s?:(.+))$/, # Apple Mail (de), Gmail (de), New Outlook 2019 (de), Thunderbird (de), HubSpot (de)
      /^(\s*De\s?:(.+))$/, # Apple Mail (es, fr, pt, pt-br), Gmail (es, fr, pt, pt-br), New Outlook 2019 (es, fr, pt, pt-br), Thunderbird (fr, pt, pt-br), HubSpot (es, fr, pt-br)
      /^(\s*Lähettäjä\s?:(.+))$/, # Apple Mail (fi), Gmail (fi), New Outlook 2019 (fi), Thunderbird (fi), HubSpot (fi)
      /^(\s*Šalje\s?:(.+))$/, # Apple Mail (hr), Gmail (hr), Thunderbird (hr)
      /^(\s*Feladó\s?:(.+))$/, # Apple Mail (hu), Gmail (hu), New Outlook 2019 (fr), Thunderbird (hu)
      /^(\s*Da\s?:(.+))$/, # Apple Mail (it), Gmail (it), New Outlook 2019 (it), HubSpot (it)
      /^(\s*Van\s?:(.+))$/, # Apple Mail (nl), Gmail (nl), New Outlook 2019 (nl), Thunderbird (nl), HubSpot (nl)
      /^(\s*Expeditorul\s?:(.+))$/, # Apple Mail (ro)
      /^(\s*Отправитель\s?:(.+))$/, # Apple Mail (ru)
      /^(\s*Från\s?:(.+))$/, # Apple Mail (sv), Gmail (sv), New Outlook 2019 (sv), Thunderbird (sv), HubSpot (sv)
      /^(\s*Kimden\s?:(.+))$/, # Apple Mail (tr), Thunderbird (tr)
      /^(\s*Від кого\s?:(.+))$/, # Apple Mail (uk)
      /^(\s*Saatja\s?:(.+))$/, # Gmail (et)
      /^(\s*De la\s?:(.+))$/, # Gmail (ro)
      /^(\s*Gönderen\s?:(.+))$/, # Gmail (tr)
      /^(\s*От\s?:(.+))$/, # Gmail (ru), New Outlook 2019 (ru), Thunderbird (ru)
      /^(\s*Від\s?:(.+))$/, # Gmail (uk), Thunderbird (uk)
      /^(\s*Mittente\s?:(.+))$/, # Thunderbird (it)
      /^(\s*Nadawca\s?:(.+))$/, # Thunderbird (pl)
      /^(\s*de la\s?:(.+))$/, # Thunderbird (ro)
      /^(\s*送信元：(.+))$/ # HubSpot (ja)
    ]

    FROM_LAX_REGEXPS = [
      /(\s*From\s?:(.+?)\s?\n?\s*[\[|<](.+?)[\]|>])/, # Yahoo Mail (en)
      /(\s*Od\s?:(.+?)\s?\n?\s*[\[|<](.+?)[\]|>])/, # Yahoo Mail (cs, pl, sk)
      /(\s*Fra\s?:(.+?)\s?\n?\s*[\[|<](.+?)[\]|>])/, # Yahoo Mail (da, no)
      /(\s*Von\s?:(.+?)\s?\n?\s*[\[|<](.+?)[\]|>])/, # Yahoo Mail (de)
      /(\s*De\s?:(.+?)\s?\n?\s*[\[|<](.+?)[\]|>])/, # Yahoo Mail (es, fr, pt, pt-br)
      /(\s*Lähettäjä\s?:(.+?)\s?\n?\s*[\[|<](.+?)[\]|>])/, # Yahoo Mail (fi)
      /(\s*Feladó\s?:(.+?)\s?\n?\s*[\[|<](.+?)[\]|>])/, # Yahoo Mail (hu)
      /(\s*Da\s?:(.+?)\s?\n?\s*[\[|<](.+?)[\]|>])/, # Yahoo Mail (it)
      /(\s*Van\s?:(.+?)\s?\n?\s*[\[|<](.+?)[\]|>])/, # Yahoo Mail (nl)
      /(\s*De la\s?:(.+?)\s?\n?\s*[\[|<](.+?)[\]|>])/, # Yahoo Mail (ro)
      /(\s*От\s?:(.+?)\s?\n?\s*[\[|<](.+?)[\]|>])/, # Yahoo Mail (ru)
      /(\s*Från\s?:(.+?)\s?\n?\s*[\[|<](.+?)[\]|>])/, # Yahoo Mail (sv)
      /(\s*Kimden\s?:(.+?)\s?\n?\s*[\[|<](.+?)[\]|>])/, # Yahoo Mail (tr)
      /(\s*Від\s?:(.+?)\s?\n?\s*[\[|<](.+?)[\]|>])/ # Yahoo Mail (uk)
    ]

     MAILBOX_REGEXP = [
      /^\s?\n?\s*<.+?<mailto\:(.+?)>>/, # "<walter.sheltan@acme.com<mailto:walter.sheltan@acme.com>>"
      /^(.+?)\s?\n?\s*<.+?<mailto\:(.+?)>>/, # "Walter Sheltan <walter.sheltan@acme.com<mailto:walter.sheltan@acme.com>>"
      /^(.+?)\s?\n?\s*[\[|<]mailto\:(.+?)[\]|>]/, # "Walter Sheltan <mailto:walter.sheltan@acme.com>" or "Walter Sheltan [mailto:walter.sheltan@acme.com]" or "walter.sheltan@acme.com <mailto:walter.sheltan@acme.com>"
      /^\'(.+?)\'\s?\n?\s*[\[|<](.+?)[\]|>]/, # "'Walter Sheltan' <walter.sheltan@acme.com>" or "'Walter Sheltan' [walter.sheltan@acme.com]" or "'walter.sheltan@acme.com' <walter.sheltan@acme.com>"
      /^\"\'(.+?)\'\"\s?\n?\s*[\[|<](.+?)[\]|>]/, # ""'Walter Sheltan'" <walter.sheltan@acme.com>" or ""'Walter Sheltan'" [walter.sheltan@acme.com]" or ""'walter.sheltan@acme.com'" <walter.sheltan@acme.com>"
      /^\"(.+?)\"\s?\n?\s*[\[|<](.+?)[\]|>]/, # ""Walter Sheltan" <walter.sheltan@acme.com>" or ""Walter Sheltan" [walter.sheltan@acme.com]" or ""walter.sheltan@acme.com" <walter.sheltan@acme.com>"
      /^([^,;]+?)\s?\n?\s*[\[|<](.+?)[\]|>]/, # "Walter Sheltan <walter.sheltan@acme.com>" or "Walter Sheltan [walter.sheltan@acme.com]" or "walter.sheltan@acme.com <walter.sheltan@acme.com>"
      /^(.?)\s?\n?\s*[\[|<](.+?)[\]|>]/, # "<walter.sheltan@acme.com>"
      /^([^\s@]+@[^\s@]+\.[^\s@,]+)/, # "walter.sheltan@acme.com"
      /^([^;].+?)\s?\n?\s*[\[|<](.+?)[\]|>]/, # "Walter, Sheltan <walter.sheltan@acme.com>" or "Walter, Sheltan [walter.sheltan@acme.com]"
    ]
  end
end