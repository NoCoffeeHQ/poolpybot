# frozen_string_literal: true

class ApplicationController < ActionController::Base

  private

  def services
    @services ||= ApplicationContainer.new
  end
end
