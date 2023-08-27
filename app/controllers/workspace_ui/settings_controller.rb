# frozen_string_literal: true

module WorkspaceUI
  class SettingsController < BaseController
    def edit
      @user_invitation = UserInvitation.new
    end
  end
end
