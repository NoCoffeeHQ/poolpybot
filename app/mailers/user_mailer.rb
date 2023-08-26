# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def reset_password_email(user)
    @user = User.find(user.id)
    @url = edit_authentication_password_reset_url(token: @user.reset_password_token)
    mail to: user.email, subject: t('.subject')
  end

  def send_invitation(invitation, invited_by, user_exists)
    @invitation = invitation
    @invited_by = invited_by
    @url = invitation_url(invitation, user_exists)
    mail to: invitation.email, subject: t('.subject')
  end

  private

  def invitation_url(invitation, user_exists)
    token = invitation.token
    if user_exists
      edit_workspace_user_invitation_confirmation_url(token)
    else
      new_sign_up_url(token: token)
    end
  end
end
