class DemandeMailer < ApplicationMailer
  default from: 'Support@docpro.tn'
  def send_mail_demande(user, demande)
    @user = user
    @demande = demande
    @greeting = "Hi"
    mail to: user.email, :subject => 'Demande Status'
  end
end