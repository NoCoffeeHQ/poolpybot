# frozen_string_literal: true

require 'mail'

module BrevoSupport
  def from_brevo(item)
    Mail.new(brevo_core_attributes(item)).tap do |mail|
      brevo_set_text_and_html_parts(mail, item)
      brevo_set_attachments(mail, item)
    end
  end

  def brevo_core_attributes(item)
    {
      message_id: item.dig('Headers', 'Message-ID'),
      date: item.dig('Headers', 'Date'),
      from: item.dig('Headers', 'From'),
      to: item.dig('Headers', 'To'),
      subject: item['Subject']
    }
  end

  def brevo_set_text_and_html_parts(mail, item)
    mail.text_part = Mail::Part.new do
      body item['RawTextBody'].gsub(/^> /, '')
    end
    mail.html_part = Mail::Part.new do
      content_type 'text/html; charset=UTF-8'
      body item['RawHtmlBody'].gsub(/^> /, '')
    end
  end

  def brevo_set_attachments(mail, item)
    item['Attachments'].each_with_index do |attachment, index|
      mail.attachments["brevo-attachment-#{index}.json"] = attachment.to_json
    end
  end
end

Mail.singleton_class.send :prepend, BrevoSupport
