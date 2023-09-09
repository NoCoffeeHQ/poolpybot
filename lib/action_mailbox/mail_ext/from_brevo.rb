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
      to: (([] + item['Recipients']) << item.dig('Headers', 'To')).compact.uniq,
      subject: item['Subject']
    }
  end

  def brevo_set_text_and_html_parts(mail, item)
    mail.text_part = Mail::Part.new do
      body item['RawTextBody'].gsub(/^> /, '')
    end
    mail.html_part = Mail::Part.new do
      content_type 'text/html; charset=UTF-8'
      body item['RawHtmlBody']&.gsub(/^> /, '')
    end
  end

  def brevo_set_attachments(mail, item)
    item['Attachments'].each_with_index do |attachment, index|
      mail.attachments["brevo-attachment-#{index}.json"] = attachment.to_json
    end
  end

  def brevo_decode_attachments(mail, only_pdf: false, api_instance: nil)
    api_instance ||= BrevoRuby::InboundParsingApi.new

    brevo_attachment_filenames = []

    mail.attachments.each do |attachment|
      next unless attachment.filename =~ /^brevo-attachment-\d+\.json/

      decoded = brevo_decode_attachment(mail, attachment, only_pdf: only_pdf, api_instance: api_instance)

      brevo_attachment_filenames << attachment.filename if decoded
    end

    mail.parts.recursive_delete_if { |part| brevo_attachment_filenames.include?(part.filename) }
  end

  private

  def brevo_decode_attachment(mail, attachment, only_pdf: false, api_instance: nil)
    json = JSON.parse(attachment.read)

    # HACK: to avoid downloading unecessary attachment document
    return if only_pdf && json['ContentType'] != 'application/pdf'

    brevo_add_file_from_json(mail, json, api_instance)
  end

  def brevo_add_file_from_json(mail, json, api_instance)
    mail.attachments[json['Name']] = {
      filename: json['Name'],
      mime_type: json['ContentType'],
      content: File.read(
        api_instance.get_inbound_email_attachment(json['DownloadToken']).path # TmpFile
      )
    }
  end
end

Mail.singleton_class.send :prepend, BrevoSupport
