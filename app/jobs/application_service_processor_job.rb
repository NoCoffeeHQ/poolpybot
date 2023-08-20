# frozen_string_literal: true

class ApplicationServiceProcessorJob < ApplicationJob
  queue_as :default

  def perform(service_name:, data:)
    find_service(service_name).call_from_job(**data)
  end

  protected

  def find_service(name)
    application_container.send(name.to_sym)
  end
end
