class Api::Mobile::RegistrationsController < ApplicationController
    def confirm_email
        user = User.find_by(email: params[:email])
        if user.confirmation_code_expired?
            user.update(confirmation_code: nil)
            render json: { errors: "confirmation code expires" }
            return false
        end
        if user&.validate_confirmation_code(params[:confirmation_code])
        render json: { message: 'Email confirmed successfully' }, status: :ok
        else
        render json: { error: 'Invalid confirmation code' }, status: :unprocessable_entity
        end
    end
    # TO DO LATER for resend code confirmation
    # def resend_code
    #     user = User.find_by(email: params[:email])
    #     if user && user.confirmation_code == nil
    #         user.confirmation_code = generate_confirmation_code
    #         user.confirmation_code_generated_at = Time.current
    #         UserMailer.confirmation_email(user).deliver
    
    #     end
    # end
    def create
        user_class = case params[:registration][:type]
                    when "Admin" then User
                    when "Doctor" then Doctor
                    else Patient
                    end
        user = user_class.new(user_params)
        user.confirmation_code = generate_confirmation_code
        user.confirmation_code_generated_at = Time.current

        if user.save
        UserMailer.confirmation_email(user).deliver
        session[:user_id] = user.id
        render json: { status: :created, user: user }
        else
        render json: { status: 500, errors: user.errors.full_messages }
        end
    end

    private

    def user_params
        params.require(:registration).permit(:lastname, :firstname, :email, :password, :password_confirmation, :type, :location)
    end

    def generate_confirmation_code
        rand.to_s[2..7]
    end
end
