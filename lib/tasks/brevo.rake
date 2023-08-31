# frozen_string_literal: true

namespace :brevo do
  desc 'List the Brevo webhooks'
  task list_webhooks: :environment do
    api_instance = BrevoRuby::WebhooksApi.new
    result = api_instance.get_webhooks(type: 'inbound')
    result.webhooks.each do |webhook|
      puts webhook
    end
  end

  desc 'List the last Brevo inbound email events'
  task list_inbound_email_events: :environment do
    action_mailbox_password = Rails.application.credentials.action_mailbox.ingress_password
    api_instance = BrevoRuby::InboundParsingApi.new
    api_instance.get_inbound_email_events.events[0..10].each do |event|
      pp api_instance.get_inbound_email_events_by_uuid(event.uuid)
    end
  end

  desc 'Create a local Brevo webhook (require the Ngrok URL in first argument)'
  task create_local_webhook: :environment do
    # rubocop:disable Style/BlockDelimiters
    ARGV.each { |a| task a.to_sym => :environment do; end }
    # rubocop:enable Style/BlockDelimiters
    action_mailbox_password = Rails.application.credentials.action_mailbox.ingress_password
    api_instance = BrevoRuby::WebhooksApi.new
    webhook = BrevoRuby::CreateWebhook.new(
      type: 'inbound',
      events: ['inboundEmailProcessed'],
      url: "#{ARGV[0]}/rails/action_mailbox/brevo/inbound_emails/#{action_mailbox_password}",
      domain: ENV['INBOUND_REPLY_EMAIL_DOMAIN'],
      description: "webhook-#{Rails.env}"
    )
    begin
      result = api_instance.create_webhook(webhook)
      puts "Webhook ##{result.id} created ✅"
    rescue BrevoRuby::ApiError => e
      puts "Exception when calling WebhooksApi->create_webhook: #{e}"
      puts e.response_body
    end
  end

  desc 'Delete all the local Brevo webhooks'
  task delete_local_webhooks: :environment do
    api_instance = BrevoRuby::WebhooksApi.new
    result = api_instance.get_webhooks(type: 'inbound')
    result.webhooks.each do |webhook|
      api_instance.delete_webhook(webhook[:id])
      puts "Webhook ##{webhook[:id]} deleted ✅"
    end
  end
end
