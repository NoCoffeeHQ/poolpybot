# frozen_string_literal: true

module WorkspaceUI
  class UserInvitationConfirmationController < BaseController
    def create
      user_invitation.accept!(current_user)
      redirect_to edit_workspace_settings_path, notice: t('.flash.success', company: current_user.company.name)
    end

    def destroy
      user_invitation.destroy
      redirect_to edit_workspace_settings_path, notice: t('.flash.success')
    end

    private

    def user_invitation
      @user_invitation = UserInvitation.by_email(current_user.email).first
    end
  end
end