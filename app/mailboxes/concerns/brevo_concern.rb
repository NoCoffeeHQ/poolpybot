# frozen_string_literal: true

module BrevoConcern
  extend ActiveSupport::Concern

  included do
    before_processing :decode_brevo_attachments
  end

  def decode_brevo_attachments
    return unless brevo_mail?

    Mail.brevo_decode_attachments(mail, only_pdf: true)
  end

  def brevo_mail?
    mail.attachments.any? { |attachment| attachment.filename.starts_with?('brevo-attachment-') }
  end
end
