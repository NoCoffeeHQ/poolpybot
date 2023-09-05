# frozen_string_literal: true

module WorkspaceUI
  class NotificationsController < BaseController
    include Pagy::Backend

    before_action :mark_as_read

    def index
      @pagy, @notifications = pagy(current_company.notifications.optimized.ordered, items: 5)
      respond_to do |format|
        format.turbo_stream
      end
    end

    private 
    
    def mark_as_read
      return unless params[:page].blank?
      current_user.update_attribute(:notifications_read_at, Time.zone.now)
    end
  end
end