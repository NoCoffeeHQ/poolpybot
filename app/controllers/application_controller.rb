# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :current_company

  private

  def services
    @services ||= ApplicationContainer.new
  end

  def not_authenticated
    redirect_to sign_in_path, alert: t('notice.not_authenticated')
  end
end
