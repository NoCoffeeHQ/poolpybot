# frozen_string_literal: true

module ActionMailbox
  # == Usage
  #
  # 1. Tell Action Mailbox to accept emails from Brevo:
  #
  #        # config/environments/production.rb
  #        config.action_mailbox.ingress = :brevo
  #
  # 2. Generate a strong password that Action Mailbox can use to authenticate requests to the Brevo ingress.
  #
  #    Use <tt>bin/rails credentials:edit</tt> to add the password to your application's encrypted credentials under
  #    +action_mailbox.ingress_password+, where Action Mailbox will automatically find it:
  #
  #        action_mailbox:
  #          ingress_password: ...
  #
  #    Alternatively, provide the password in the +RAILS_INBOUND_EMAIL_PASSWORD+ environment variable.
  #
  # 3. {Configure Brevo Inbound Parse}[https://developers.brevo.com/docs/inbound-parse-webhooks]
  #    to forward inbound emails to +/rails/action_mailbox/brevo/inbound_emails/PASSWORD+ with the
  #    the password you previously generated. If your application lived at <tt>https://example.com</tt>, you would
  #    configure SendGrid with the following fully-qualified URL:
  #
  #        https://example.com/rails/action_mailbox/brevo/inbound_emails/PASSWORD
  #
  module Ingresses
    module Brevo
      class InboundEmailsController < ActionMailbox::BaseController
        before_action :authenticate_by_password

        def create
          logger.info '🔥🔥🔥🔥🔥'
          head :ok
          # ActionMailbox::InboundEmail.create_and_extract_message_id! mail
          # rescue JSON::ParserError => error
          #   logger.error error.message
          #   head :unprocessable_entity
        end

        private

        def authenticate_by_password
          raise ArgumentError, 'Missing required ingress credentials' if password.blank?

          head :unauthorized unless password == params[:password]
        end

        # def mail
        #   params.require(:email).tap do |raw_email|
        #     envelope["to"].each { |to| raw_email.prepend("X-Original-To: ", to, "\n") } if params.key?(:envelope)
        #   end
        # end

        # def envelope
        #   JSON.parse(params.require(:envelope))
        # end
      end
    end
  end
end
