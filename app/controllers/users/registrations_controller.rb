class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  # POST /registrations
  def create
    # Determine the user type dynamically
    user_class = case params[:registration][:type]
                  when "Admin" then User
                  when "Doctor" then Doctor
                  else Patient
                end

    # Build the user object
    user = user_class.new(sign_up_params)

    if user.save
      # Send confirmation email
      UserMailer.registration_confirmation(user).deliver

      # Log the user in
      sign_in(user)

      render json: { status: :created, user: user }, status: :created
    else
      render json: { status: 500, errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /registrations/:id/confirm_email
  def confirm_email
    user = User.find_by(confirm_token: params[:id])
    if user
      user.update(email_confirmed: true, confirm_token: nil)
      redirect_to 'http://localhost:4200/login'
    else
      render json: { status: 500, message: 'Invalid token' }, status: :unprocessable_entity
    end
  end

  private

  # Allow additional parameters for sign-up
  def sign_up_params
    params.require(:registration).permit(
      :lastname, :firstname, :email, :password, :password_confirmation, 
      :type, :location, :gender
    )
  end
end
