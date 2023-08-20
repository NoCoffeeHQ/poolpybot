# frozen_string_literal: true

class ApplicationService < ServiceOrchestrator::Service
  def call_later(**data)
    logger.debug "🤔 service_name = #{service_name} / #{data}"
    ApplicationServiceProcessorJob.perform_later(service_name: service_name.to_s, data: data)
  end

  def call_from_job(**_data)
    raise 'TO BE IMPLEMENTED'
  end

  private

  def logger
    Rails.logger
  end

  # def service_name
  #   pp [@service_name, application_container.dependencies]
  #   # WARNING: it won't work well if 2 different dependencies have the same class.
  #   @service_name ||= application_container.dependencies.select do |_, service|
  #
  #     pp [service.class.name, self.class.name]

  #     service.class.name == self.class.name
  #       #   end.first&.first # select returns an array of arrays [key, value]
  # end

  # def application_container
  #   # TODO: find something better. Alternatives:
  #   # - set the container when calling the service and fallback to the `ApplicationContainer.new`
  #   # - global container?
  #   ApplicationContainer.new
  # end
end
