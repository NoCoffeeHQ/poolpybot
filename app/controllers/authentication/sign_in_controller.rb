# frozen_string_literal: true

module Authentication
  class SignInController < Authentication::BaseController
    def new
      @user = User.new
    end

    def create
      @user = login(sign_in_params[:email], sign_in_params[:password]) || User.new

      if @user.persisted?
        redirect_back_or_to dashboard_path, notice: t('.notice.success')
      else
        flash.now[:alert] = t('.notice.fail')
        render action: 'new', status: :unprocessable_entity
      end
    end

    def destroy
      logout
      redirect_to root_path
    end

    private

    def sign_in_params
      params.require(:user).permit(:email, :password)
    end
  end
end
