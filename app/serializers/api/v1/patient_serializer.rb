class Api::V1::PatientSerializer < ActiveModel::Serializer
  attributes :id, :lastname, :firstname, :phone_number, :email, :email_confirmed, :user_image_url, :created_at

  def created_at
    object.created_at.strftime("%d.%m.%Y")
  end 

  def user_image_url
    object.user_image_url
  end
end
