# app/mailers/notification_mailer.rb
class NotificationMailer < ApplicationMailer
  def send_room_code(doctor, patient, room_code)
    @doctor = doctor
    @patient = patient
    @room_code = room_code

    # Set the email subject
    mail(to: @patient.email, subject: 'Your Consultation Room Link') do |format|
      format.html { render 'send_room_code' }
    end
    mail(to: @doctor.email, subject: 'Your Consultation Room Link') do |format|
      format.html { render 'send_room_code' }
    end
    # Track sent email in the database
    CustomMail.create!(
      doctor_id: @doctor.id,
      patient_id: @patient.id,
      subject: 'Your Consultation Room Link',
      body: "Hello ,<br>Your consultation room link is:  <strong><a href='http://localhost:4200/live/#{@room_code}'>Join Consultation</a></strong><br>Best regards,<br> Doc Pro System",
      status: 'sent',
      sent_at: Time.current
    )
  end
end
