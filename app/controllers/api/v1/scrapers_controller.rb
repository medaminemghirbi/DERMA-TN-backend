class Api::V1::ScrapersController < ApplicationController
  def run
    csv_file_path = Rails.root.join('app/services/doctors_data.csv')

    # Check if the CSV file exists
    unless File.exist?(csv_file_path)
      RunScraper.call
    end
    CSV.foreach(csv_file_path, headers: true) do |row|
      firstname = row['name'].split(' ')[0]
      lastname = row['name'].split(' ')[1..].join(' ')
      location = row['location']

      doctor_exists = Doctor.exists?(firstname: firstname, lastname: lastname, location: location)

      unless doctor_exists
        doctor = Doctor.create!(
          firstname: firstname,
          lastname: lastname,
          location: location,
          description: row['description'],
          google_maps_url: row['google_maps_url'],
          phone_number: row['phone_number'].presence || "",
          email: Faker::Internet.unique.email,
          password: "123456",
          password_confirmation: "123456",
          email_confirmed: true
        )

        # Download and attach the avatar if present
        if row['avatar_src'].present?
          avatar_url = row['avatar_src']
          avatar_file = URI.open(avatar_url)
          doctor.avatar.attach(io: avatar_file, filename: File.basename(avatar_url), content_type: avatar_file.content_type)
        end
      end
    end

    render json: { 
      message: "Doctors successfully imported!"
    }
  end
end
