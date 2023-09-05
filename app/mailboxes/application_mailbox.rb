# frozen_string_literal: true

class ApplicationMailbox < ActionMailbox::Base
  # Email used by Google to send the code to verify a forwarded address.
  GMAIL_FORWARDING_EMAIL = 'forwarding-noreply@google.com'

  # rubocop:disable Lint/AmbiguousRegexpLiteral, Style/RedundantRegexpEscape
  routing ->(inbound_email) { inbound_email.mail.from.include?(GMAIL_FORWARDING_EMAIL) } => :gmail_forwarding_code
  
  routing /\@#{ENV['INBOUND_REPLY_EMAIL_DOMAIN']}$/i => :invoices
  # rubocop:enable Lint/AmbiguousRegexpLiteral, Style/RedundantRegexpEscape  
end
