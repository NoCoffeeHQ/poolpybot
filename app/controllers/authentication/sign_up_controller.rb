# frozen_string_literal: true

module Authentication
  class SignUpController < Authentication::BaseController
    before_action :fetch_invitation

    def new
      @company = @invitation ? @invitation.company : Company.new
      @user = @invitation ? User.new(email: @invitation.email) : User.new
    end

    def create
      @company = Company.new(company_params)
      @user = User.new(user_params)

      if services.onboarding.call(company: @company, user: @user, invitation: @invitation)
        auto_login(@user)
        redirect_to workspace_root_path, notice: t('.flash.success')
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def company_params
      params.require(:company).permit(:name)
    end

    def user_params
      params.require(:user).permit(:username, :email, :password).tap do |permitted_params|
        permitted_params[:password_confirmation] = permitted_params[:password]
        permitted_params[:locale] = I18n.locale
      end
    end

    def fetch_invitation
      @invitation = UserInvitation.by_token(params[:token]).first
    end
  end
end
