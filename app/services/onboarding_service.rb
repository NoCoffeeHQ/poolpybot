# frozen_string_literal: true

class OnboardingService < ApplicationService
  def call(user:, company:, invitation: nil)
    ActiveRecord::Base.transaction do
      unsafe_call(company, user, invitation)
    end
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def unsafe_call(company, user, invitation)
    user.valid? # call all the validations (for the HTML form)
    
    company.save! unless invitation
     
    user.company = invitation ? invitation.company : company
    user.save!

    invitation.destroy if invitation

    true
  end
end
