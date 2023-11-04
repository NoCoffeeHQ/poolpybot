# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def reset_password_email(user)
    @user = User.find(user.id)
    @url = edit_authentication_password_reset_url(token: @user.reset_password_token)
    I18n.with_locale(@user.locale) do
      mail to: @user.email, subject: t('.subject')
    end
  end

  def send_invitation(invitation, user_exists)
    @invitation = invitation
    @invited_by = invitation.invited_by
    @url = invitation_url(invitation, user_exists)
    mail to: invitation.email, subject: t('.subject')
  end

  def invoices_export(user, date, zipfile)
    @user = user
    @date = I18n.l(date, format: :month)
    attachments["poolpybot-invoices-#{date.strftime('%Y-%m')}.zip"] = File.read(zipfile.path)
    I18n.with_locale(@user.locale) do
      mail to: @user.email, subject: t('.subject')
    end
  end

  def notify(notification)
    @user = notification.user
    @event = notification.event
    @data = notification.full_data
    I18n.with_locale(@user.locale) do
      mail to: @user.email, subject: t(".#{notification.event}.subject")
    end
  end

  def daily_activity_digest(user, notifications, date)
    @user = user
    @notifications = notifications
    I18n.with_locale(@user.locale) do
      mail to: @user.email, subject: t('.subject', date: date.strftime('%Y-%m-%d'))
    end
  end

  def weekly_activity_digest(user, notifications, begin_date, end_date)
    @user = user
    @notifications = notifications
    I18n.with_locale(@user.locale) do
      mail to: @user.email,
           subject: t('.subject', begin_date: begin_date.strftime('%Y-%m-%d'), end_date: end_date.strftime('%Y-%m-%d'))
    end
  end

  private

  def invitation_url(invitation, user_exists)
    token = invitation.token
    if user_exists
      edit_workspace_settings_url
    else
      new_sign_up_url(token: token)
    end
  end
end
