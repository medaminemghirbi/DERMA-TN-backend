require 'faker'
require 'open-uri'
require 'yaml'
require 'csv'
puts "seeding"
Admin.create(  email: "Admin@example.com", firstname: "Admin", lastname:"Admin", password: "123456", password_confirmation: "123456", email_confirmed: true)
  10.times do
    patient = Patient.create(
      email: Faker::Internet.unique.email,
      firstname: Faker::Name.first_name,
      lastname: Faker::Name.last_name,
      password: "123456",
      password_confirmation: "123456",
      email_confirmed: true
    )
    downloaded_image = URI.open(Faker::Avatar.image)
    patient.avatar.attach(io: downloaded_image, filename: "#{patient.firstname}_avatar.jpg", content_type: 'image/jpg')
    puts "Created patient: #{patient.firstname} #{patient.lastname} (#{patient.email})"

    # latitude = Faker::Number.between(from: 24.396308, to: 49.384358)
    # longitude = Faker::Number.between(from: -125.0, to: -66.93457)
    #   google_maps_url = "https://www.google.com/maps/search/?api=1&query=#{latitude},#{longitude}"
    # doctor = Doctor.create(
    #   email: Faker::Internet.unique.email,
    #   firstname: Faker::Name.first_name,
    #   lastname: Faker::Name.last_name,
    #   password: "123456",
    #   latitude: latitude,
    #   longitude: longitude,
    #   google_maps_url: google_maps_url,
    #   password_confirmation: "123456",
    #   email_confirmed: true
    # )
  
    # # Attach a random avatar from the internet
    # avatar_url = Faker::Avatar.image # Generates a random avatar image URL
    # downloaded_image = URI.open(avatar_url)
    
    # doctor.avatar.attach(io: downloaded_image, filename: "#{doctor.firstname}_avatar.jpg", content_type: 'image/jpg')
  
    #puts "Created doctor: #{doctor.firstname} #{doctor.lastname} (#{doctor.email})"

  end


  ##Load Doctors from csv
  csv_file_path = Rails.root.join('db', 'doctors.csv')

  CSV.foreach(csv_file_path, headers: true) do |row|
    doctor = Doctor.create!(
      firstname: row['name'].split(' ')[0],
      lastname: row['name'].split(' ')[1..].join(' '),
      location: row['location'],
      description: row['description'],
      google_maps_url: row['google_maps_url'],
      phone_number: row['phone_number'].presence || "",
      email: Faker::Internet.unique.email,
      password: "123456",
      password_confirmation: "123456",
      email_confirmed: true
    )
  
    # Download and attach the avatar
    if row['avatar_src'].present?
      avatar_url = row['avatar_src']
      avatar_file = URI.open(avatar_url)
      doctor.avatar.attach(io: avatar_file, filename: File.basename(avatar_url), content_type: avatar_file.content_type)
    end
  end
  puts "Doctors successfully imported with avatars!"
    
# Load diseases data from YAML file
YAML.load_file(Rails.root.join('db', 'diseases.yml')).each do |disease_data|
  # Extract data from the YAML file
  disease_name = disease_data['maladie_name']
  description = disease_data['maladie_description']
  synonyms = disease_data['synonyms']
  symptoms = disease_data['symptoms']
  causes = disease_data['causes']
  treatments = disease_data['treatments']
  prevention = disease_data['prevention']
  diagnosis = disease_data['diagnosis']
  references = disease_data['references']
  image_path = Rails.root.join('app', 'assets', 'images', disease_data['image_path']).to_s
  
  # Create the Disease record
  disease = Maladie.create(
    maladie_name: disease_name,
    maladie_description: description,
    synonyms: synonyms,
    symptoms: symptoms,
    causes: causes,
    treatments: treatments,
    prevention: prevention,
    diagnosis: diagnosis,
    references: references
  )
  # Attach the image
  if File.exist?(image_path)
    disease.image.attach(io: File.open(image_path), filename: disease_data['image_path'], content_type: 'image/png')
  else
    puts "Image not found: #{image_path}"
  end
  puts "Created disease: #{disease_name}"
  puts "seeding done"
end
