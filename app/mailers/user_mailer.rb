class UserMailer < ApplicationMailer
  default from: "DocPro@System.com"
  # def registration_confirmation(user)
  #   @user = user
  #   @confirmation_link = confirm_email_registration_url(user.confirm_token)
  #   mail(to: " <#{@user.email}>", subject: "Email  Confirmation")
  # end

  # def forgot_password(user)
  #   @user = user
  #   @greeting = "Hi"
  #   mail to: user.email, subject: "Reset password instructions"
  # end

  # def confirmation_email(user)
  #   @user = user
  #   @confirmation_code = user.confirmation_code
  #   mail(to: @user.email, subject: "Email Confirmation Code")
  # end


  include Rails.application.routes.url_helpers

  def registration_confirmation(user)
    @user = user
    @confirmation_link = user_confirmation_url(confirmation_token: @user.confirmation_token, host: 'localhost', port: 3000)
    mail(to: @user.email, subject: 'Email Confirmation')
  end

end
