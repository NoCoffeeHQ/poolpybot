# frozen_string_literal: true

require 'brevo-ruby'

# Setup authorization
BrevoRuby.configure do |config|
  # Configure API key authorization: api-key
  config.api_key['api-key'] = Rails.application.credentials.brevo_api_key

  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['api-key'] = 'Bearer'

  # Configure API key authorization: partner-key
  # config.api_key['partner-key'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['partner-key'] = 'Bearer'
end
