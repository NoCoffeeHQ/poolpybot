# frozen_string_literal: true

class ApplicationContainer < ServiceOrchestrator::Container
  register :onboarding, 'OnboardingService'
end
