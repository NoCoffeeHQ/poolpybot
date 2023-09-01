# frozen_string_literal: true

require 'sidekiq/web'

require 'aws-sdk-s3' if Sidekiq.server?
