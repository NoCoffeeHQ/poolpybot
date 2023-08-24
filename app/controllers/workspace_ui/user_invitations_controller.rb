# frozen_string_literal: true

module WorkspaceUI
  class UserInvitationsController < BaseController
    def create
      @user_invitation = UserInvitation.create_or_resend(sent_by: current_user, email: user_invitation_params[:email])

      if @user_invitation.errors.empty?
        respond_to do |format|
          format.html { redirect_to edit_workspace_settings_path, notice: t('.flash.success') }
          format.turbo_stream { flash.now[:notice] = t('.flash.success') }
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def user_invitation_params
      params.require(:user_invitation).permit(:email)
    end
  end
end