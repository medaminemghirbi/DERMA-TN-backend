class UserMailer < ApplicationMailer
  default from: "DocPro@System.com"
  def registration_confirmation(user)
    @user = user
    mail(to: " <#{user.email}>", subject: "Registration Confirmation")
  end

  def forgot_password(user)
    @user = user
    @greeting = "Hi"
    mail to: user.email, subject: "Reset password instructions"
  end

  def confirmation_email(user)
    @user = user
    @confirmation_code = user.confirmation_code
    mail(to: @user.email, subject: "Email Confirmation Code")
  end
end
