# frozen_string_literal: true

module WorkspaceUI
  class MyProfileController < BaseController
    def update
      if current_user.update(user_params)
        respond_to do |format|
          format.html { redirect_to edit_workspace_settings_path, notice: t('.flash.success') }
          format.turbo_stream { flash.now[:notice] = t('.flash.success') }
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:username, :email, :password, :avatar)
    end
  end
end