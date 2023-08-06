# frozen_string_literal: true

class ApplicationMailbox < ActionMailbox::Base
  # rubocop:disable Lint/AmbiguousRegexpLiteral, Style/RedundantRegexpEscape
  routing /\@#{ENV['INBOUND_REPLY_EMAIL_DOMAIN']}$/i => :invoices
  # rubocop:enable Lint/AmbiguousRegexpLiteral, Style/RedundantRegexpEscape
end
