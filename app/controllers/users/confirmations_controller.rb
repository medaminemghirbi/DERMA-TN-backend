# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  # GET /resource/confirmation?confirmation_token=abcdef
  # def show
  #   super
  # end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end
  def confirm
    # You can add custom logic here

    # Find the user based on the token
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      # You can customize the redirect here
      flash[:notice] = "Your email has been successfully confirmed."
      redirect_to 'http://localhost:4020'  # Or any other URL you want
    else
      # If there's an error, you can customize the failure behavior
      flash[:alert] = "There was a problem confirming your email."
      redirect_to new_user_session_path
    end
  end
end
