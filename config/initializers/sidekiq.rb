# frozen_string_literal: true

require 'sidekiq/web'

if Sidekiq.server?
  require 'aws-sdk-s3'
end