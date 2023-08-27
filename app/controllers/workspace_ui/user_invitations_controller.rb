# frozen_string_literal: true

module WorkspaceUI
  class UserInvitationsController < BaseController
    def create
      @user_invitation = UserInvitation.invite(email: user_invitation_params[:email], invited_by: current_user)

      if @user_invitation.errors.empty?
        respond_to do |format|
          format.html { redirect_to edit_workspace_settings_path, notice: t('.flash.success') }
          format.turbo_stream { after_success(t('.flash.success')) }
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      current_company.user_invitations.find(params[:id]).destroy
      respond_to do |format|
        format.html { redirect_to edit_workspace_settings_path, notice: t('.flash.success') }
        format.turbo_stream { after_success(t('.flash.success')) }
      end
    end

    private

    def user_invitation_params
      params.require(:user_invitation).permit(:email)
    end

    def after_success(message)
      flash.now[:notice] = message
      @user_invitation = UserInvitation.new
    end
  end
end
