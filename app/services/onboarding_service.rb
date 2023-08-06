# frozen_string_literal: true

class OnboardingService < ApplicationService
  def call(user:, company:)
    ActiveRecord::Base.transaction do
      user.valid? # call all the validations (for the HTML form)
      company.save!
      company.reload # reload is used to get the uuid from the DB
      user.company = company
      user.save!
    end
  rescue ActiveRecord::RecordInvalid
    false
  end
end
