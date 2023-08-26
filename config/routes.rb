# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  # Authentication
  get 'sign_up', to: 'authentication/sign_up#new', as: :new_sign_up
  post 'sign_up', to: 'authentication/sign_up#create', as: :sign_up

  get 'sign_in', to: 'authentication/sign_in#new', as: :new_sign_in
  post 'sign_in', to: 'authentication/sign_in#create', as: :sign_in
  post 'sign_out', to: 'authentication/sign_in#destroy', as: :sign_out

  namespace :authentication do
    resource :password_reset, controller: 'password_reset', only: %i[new create edit update]
  end

  # ActionMailbox
  scope '/rails/action_mailbox', module: 'action_mailbox/ingresses' do
    post '/brevo/inbound_emails/:password', to: 'brevo/inbound_emails#create', as: :rails_brevo_inbound_emails
  end

  scope '/workspace', module: 'workspace_ui', as: :workspace do
    root to: 'home#index'
    resources :invoices, only: %i[index] do
      post :bulk_create, on: :collection
    end
    resource :settings, controller: 'settings', only: %i[edit]
    resource :my_profile, controller: 'my_profile', only: %i[update]
    resource :company, controller: 'company', only: %i[update]
    resources :user_invitations, only: %i[create destroy]
    resources :user_invitation_confirmations, only: %i[edit update]
  end

  # Very secure URLs to get the invoice HTML or PDF document
  resources :invoice_documents, only: [:show]

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
# rubocop:enable Metrics/BlockLength
