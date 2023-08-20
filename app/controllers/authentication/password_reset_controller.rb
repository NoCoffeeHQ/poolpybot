# frozen_string_literal: true

module Authentication
  class PasswordResetController < Authentication::BaseController
    before_action :fetch_user, only: %i[edit update]

    def new
      @user = User.new
    end

    def create
      @user = User.find_by(email: params[:user][:email])

      @user&.deliver_reset_password_instructions!

      # Tell the user instructions have been sent whether or not email was found.
      # This is to not leak information to attackers about which emails exist in the system.
      redirect_to new_sign_in_path, notice: t('.notice.success')
    end

    def edit
      # please Rubocop
    end

    # This action fires when the user has sent the reset password form.
    def update
      # the next line makes the password confirmation validation work
      @user.password_confirmation = params[:user][:password_confirmation]
      # the next line clears the temporary token and updates the password
      if @user.change_password(params[:user][:password])
        redirect_to new_sign_in_path, notice: t('.notice.success')
      else
        render action: 'edit', status: :unprocessable_entity
      end
    end

    private

    def fetch_user
      @token = params[:token]
      @user = User.load_from_reset_password_token(@token)

      redirect_to new_sign_in_path if @user.blank?
    end
  end
end
