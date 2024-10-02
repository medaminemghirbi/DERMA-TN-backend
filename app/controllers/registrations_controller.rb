class RegistrationsController < ApplicationController
  def confirm_email
    user = User.find_by(confirm_token: params[:id])
    if user
      user.update(email_confirmed: true, confirm_token: nil)
      redirect_to 'http://localhost:4200/login'
    else
      render json: { status: 500 }
    end
  end

  def create
    user_class = case params[:registration][:type]
                  when "Admin" then User
                  when "Doctor" then Doctor
                  else Patient
                end
    user = user_class.new(user_params)
    if user.save
      UserMailer.registration_confirmation(user).deliver
      session[:user_id] = user.id
      render json: { status: :created, user: user }
    else
      render json: { status: 500, errors: user.errors.full_messages }
    end
  end
  private
    def user_params
      params.require(:registration).permit(:lastname, :firstname, :email, :password, :password_confirmation, :type)
    end
end
