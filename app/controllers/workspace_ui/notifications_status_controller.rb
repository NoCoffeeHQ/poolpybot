# frozen_string_literal: true

module WorkspaceUI
  class NotificationsStatusController < BaseController
    def show
      respond_to do |format|
        format.json { render json: { unread: current_company.notifications.read?(current_user) } }
      end
    end
  end
end
