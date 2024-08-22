class UserSettingsController < ApplicationController
  before_action :set_user_setting, only: [:show, :update, :destroy]

  # GET /user_settings
  def index
    @user_settings = UserSetting.all
    render json: @user_settings
  end

  # GET /user_settings/:id
  def show
    render json: @user_setting
  end

  # POST /user_settings
  def create
    @user_setting = UserSetting.new(user_setting_params)
    
    if @user_setting.save
      render json: @user_setting, status: :created
    else
      render json: @user_setting.errors, status: :unprocessable_entity
    end
  end

  # PUT/PATCH /user_settings/:id
  def update
    if @user_setting.update(user_setting_params)
      render json: @user_setting
    else
      render json: @user_setting.errors, status: :unprocessable_entity
    end
  end

  # DELETE /user_settings/:id
  def destroy
    @user_setting.destroy
  end

  private
  
  # Find the UserSetting based on the ID parameter
  def set_user_setting
    @user_setting = UserSetting.find(params[:id])
  end

  # Allowlist the permitted parameters
  def user_setting_params
    params.require(:user_setting).permit(:is_emailable, :is_notifiable, :is_smsable, :is_archived, :user_id)
  end
end
