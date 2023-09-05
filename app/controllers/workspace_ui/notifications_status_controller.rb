# frozen_string_literal: true

module WorkspaceUI
  class NotificationsStatusController < BaseController

    def show
      # unread = current_user.notifications_read_at ? current_company.notifications.where(Notification[:created_at].gt(current_user.notifications_read_at)).exists? : true
      respond_to do |format|
        format.json { render json: { unread: current_company.notifications.read?(current_user) } }
      end
    end
  end
end