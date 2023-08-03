# frozen_string_literal: true

module Authentication
  class SignUpController < Authentication::BaseController
    # GET /sign_up
    def new
      @company = Company.new
      @user = User.new
    end

    # POST /sign_up
    def create
      @company = Company.new(company_params)
      @user = User.new(user_params)

      if services.onboarding.call(company: @company, user: @user)
        redirect_to dashboard_path, notice: t('notice.sign_up.success')
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
      end
    end
  end
end
