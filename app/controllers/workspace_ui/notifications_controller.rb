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
      return if params[:page].present?

      # rubocop:disable Rails/SkipsModelValidations
      current_user.update_attribute(:notifications_read_at, Time.zone.now)
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
