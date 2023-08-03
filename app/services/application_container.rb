class ApplicationContainer < ServiceOrchestrator::Container
  register :onboarding, 'OnboardingService'
end