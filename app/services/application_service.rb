# frozen_string_literal: true

class ApplicationService < ServiceOrchestrator::Service
  def call_later(**data)
    ApplicationServiceProcessorJob.perform_later(service_name: service_name.to_s, data: data)
  end

  def call_from_job(**_data)
    raise 'TO BE IMPLEMENTED'
  end

  private

  def logger
    Rails.logger
  end
end
