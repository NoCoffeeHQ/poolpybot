# frozen_string_literal: true

module WorkspaceUI
  class MyProfileController < BaseController
    def update
      if current_user.update(user_params)
        respond_to do |format|
          format.html { redirect_to edit_workspace_settings_path, notice: t('.flash.success') }
          format.turbo_stream { apply_flash_message(t('.flash.success', locale: current_user.locale)) } 
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:username, :email, :password, :avatar, :locale)
    end

    def apply_flash_message(message)
      flash_instance = current_user.locale_previously_changed? ? flash : flash.now
      flash_instance[:notice] = message
    end
  end
end
