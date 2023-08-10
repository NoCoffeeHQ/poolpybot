# frozen_string_literal: true

Rails.application.routes.draw do
  # Authentication
  get 'sign_up', to: 'authentication/sign_up#new', as: :new_sign_up
  post 'sign_up', to: 'authentication/sign_up#create', as: :sign_up

  get 'sign_in', to: 'authentication/sign_in#new', as: :new_sign_in
  post 'sign_in', to: 'authentication/sign_in#create', as: :sign_in
  post 'sign_out', to: 'authentication/sign_in#destroy', as: :sign_out

  # Routes when logged in
  get 'dashboard', to: 'dashboard#index', as: :dashboard

  # ActionMailbox
  scope '/rails/action_mailbox', module: 'action_mailbox/ingresses' do
    post '/brevo/inbound_emails/:password', to: 'brevo/inbound_emails#create', as: :rails_brevo_inbound_emails
  end

  # Sidekiq
  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      # Protect against timing attacks:
      # - See https://codahale.com/a-lesson-in-timing-attacks/
      # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
      # - Use & (do not use &&) so that it doesn't short circuit.
      # - Use digests to stop length information leaking
      ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(username),
        ::Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq_ui.username)
      ) &
        ActiveSupport::SecurityUtils.secure_compare(
          ::Digest::SHA256.hexdigest(password),
          ::Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq_ui.password)
        )
    end
  end

  mount Sidekiq::Web, at: '/sidekiq'

  # Defines the root path route ("/")
  root 'home#index'
end
