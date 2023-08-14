class Authentication::PasswordResetController < Authentication::BaseController
  
  def new
    @user = User.new
  end

  def create 
    @user = User.find_by_email(params[:user][:email])
        
    @user.deliver_reset_password_instructions! if @user
        
    # Tell the user instructions have been sent whether or not email was found.
    # This is to not leak information to attackers about which emails exist in the system.
    redirect_to new_sign_in_path, notice: t('.notice.success')
  end
    
  # This is the reset password form.
  def edit
    @token = params[:token]
    @user = User.load_from_reset_password_token(@token)

    redirect_to new_sign_in_path if @user.blank?
  end
      
  # This action fires when the user has sent the reset password form.
  def update
    @token = params[:token]
    @user = User.load_from_reset_password_token(@token)

    if @user.blank?
      not_authenticated
      return
    end

    # the next line makes the password confirmation validation work
    @user.password_confirmation = params[:user][:password_confirmation]
    # the next line clears the temporary token and updates the password
    if @user.change_password(params[:user][:password])
      redirect_to new_sign_in_path, notice: t('.notice.success')
    else
      render action: 'edit', status: :unprocessable_entity
    end
  end
end
