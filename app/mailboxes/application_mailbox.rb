# frozen_string_literal: true

class ApplicationMailbox < ActionMailbox::Base
  routing /\@#{ENV['INBOUND_REPLY_EMAIL_DOMAIN']}$/i => :invoices
end
