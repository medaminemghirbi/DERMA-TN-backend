require "faker"
require "open-uri"
require "yaml"
require "csv"
require "net/http"
require "json"

puts "Seeding data..."

########################### Seeding Admin ##################################
admin_avatar_url = "https://thumbs.dreamstime.com/b/admin-reliure-de-bureau-sur-le-bureau-en-bois-sur-la-table-crayon-color%C3%A9-79046621.jpg"
uri = URI.parse(admin_avatar_url)

response = Net::HTTP.get_response(uri)
if response.is_a?(Net::HTTPSuccess)
  admin_avatar_file = StringIO.new(response.body) # Wrap the body in a StringIO object for attachment
  admin = Admin.create!(
    email: "Admin@example.com",
    firstname: "Admin",
    lastname: "Admin",
    password: "123456",
    password_confirmation: "123456",
    email_confirmed: true
  )

  admin.avatar.attach(
    io: admin_avatar_file,
    filename: "admin_avatar.jpg",
    content_type: "image/jpeg"
  )
  puts "Admin seeded."
else
  puts "Failed to download avatar image"
end
########################### Seeding Doctors from CSV ##################################
csv_file_path = Rails.root.join("app", "services", "dermatologue_doctors.csv")
puts "Seeding 10 doctors from CSV file..."
starting_order = 1

CSV.foreach(csv_file_path, headers: true).first(6).each_with_index do |row, index|
  doctor = Doctor.create!(
    firstname: row["name"].split.first,
    lastname: row["name"].split[1..].join(" "),
    location: row["location"],
    email: Faker::Internet.unique.email,
    order: starting_order + index,
    password: "123456",
    password_confirmation: "123456",
    email_confirmed: true
  )

  3.times do
    doctor.phone_numbers.create!(
      number: Faker::PhoneNumber.phone_number,
      phone_type: ["personal", "home", "fax"].sample
    )
  end

  if row["avatar_src"].present?
    avatar_url = row["avatar_src"]
    uri = URI.parse(avatar_url)

    response = Net::HTTP.get_response(uri)
    if response.is_a?(Net::HTTPSuccess)
      avatar_file = StringIO.new(response.body) # Wrap the response in StringIO for ActiveStorage
      doctor.avatar.attach(io: avatar_file, filename: File.basename(avatar_url), content_type: response["content-type"])
    else
      puts "Failed to download avatar for Doctor #{doctor.firstname} #{doctor.lastname}"
    end
  end

  puts "Doctor #{doctor.firstname} #{doctor.lastname} seeded."
end

########################### Seeding Patients ##################################
puts "Seeding 5 patients..."
starting_order = 1

5.times do |index|
  phone_number = Faker::PhoneNumber.phone_number.gsub(/\D/, "").slice(0, 8)

  patient = Patient.create!(
    email: Faker::Internet.unique.email,
    firstname: Faker::Name.first_name,
    lastname: Faker::Name.last_name,
    password: "123456",
    order: starting_order + index,
    password_confirmation: "123456",
    phone_number: phone_number,
    location: ["sousse", "ben-arous", "bizerte", "beja", "gabes", "gafsa", "ariana", "hammamet", "monastir"].sample,
    email_confirmed: true
  )

  # Use Faker to get the avatar image URL
  avatar_url = Faker::Avatar.image

  uri = URI.parse(avatar_url)
  response = Net::HTTP.get_response(uri)

  if response.is_a?(Net::HTTPSuccess)
    # Download the image content securely
    avatar_file = StringIO.new(response.body)
    patient.avatar.attach(io: avatar_file, filename: "#{patient.firstname}_avatar.jpg", content_type: response["content-type"])
  else
    puts "Failed to download avatar for Patient #{patient.firstname} #{patient.lastname}"
  end

  puts "Patient #{patient.firstname} #{patient.lastname} seeded."
end
########################### Seeding Maladies from YAML ##################################
puts "Seeding diseases..."
starting_order = 0

YAML.load_file(Rails.root.join("db", "diseases.yml")).each do |disease_data|
  starting_order += 1

  maladie = Maladie.create!(
    maladie_name: disease_data["maladie_name"],
    maladie_description: disease_data["maladie_description"],
    synonyms: disease_data["synonyms"],
    symptoms: disease_data["symptoms"],
    causes: disease_data["causes"],
    treatments: disease_data["treatments"],
    prevention: disease_data["prevention"],
    diagnosis: disease_data["diagnosis"],
    references: disease_data["references"],
    is_cancer: disease_data["is_cancer"],
    order: starting_order
  )

  image_path = Rails.root.join("app", "assets", "images", disease_data["image_path"]).to_s
  if File.exist?(image_path)
    maladie.image.attach(io: File.open(image_path), filename: disease_data["image_path"], content_type: "image/png")
  else
    puts "Image not found for #{maladie.maladie_name}: #{image_path}"
  end
end

########################### Seeding Consultations ##################################
puts "Seeding consultations..."
def generate_random_appointment_time
  start_date = Time.now
  end_date = start_date + 30.days
  time_slots = []

  # Loop through each day in the next 30 days
  (start_date.to_date..end_date.to_date).each do |date|
    # Generate time slots for each day between 09:00 and 16:00
    start_time = Time.parse("09:00").change(year: date.year, month: date.month, day: date.day)
    end_time = Time.parse("16:00").change(year: date.year, month: date.month, day: date.day)

    while start_time <= end_time
      time_slots << start_time
      start_time += 30.minutes
    end
  end

  # Randomly select a time slot
  time_slots.sample
end
# patients = Patient.all
doctors = Doctor.all

# # Ensure there are patients and doctors available
# if patients.empty? || doctors.empty?
#   puts "No patients or doctors found in the database. Please create some first."
# else
#   # Create 1000 consultations
#   1000.times do
#     doctor = doctors.sample
#     appointment_time = generate_random_appointment_time
#     appointment_date = appointment_time.to_date  # Extract just the date for comparison

#     # Randomly select a patient
#     patient = patients.sample

#     # 1. Check if the patient already has a consultation with the same doctor on the same date
#     existing_consultation_same_day = Consultation.find_by(doctor: doctor, patient: patient, appointment: appointment_date.all_day)

#     # 2. Check if there's already a consultation for the doctor at the exact same time
#     existing_consultation_same_time = Consultation.find_by(doctor: doctor, appointment: appointment_time)

#     # Loop until a valid consultation is found
#     while existing_consultation_same_day || existing_consultation_same_time
#       puts "Conflicts detected: "

#       if existing_consultation_same_day
#         puts "Patient #{patient.id} already has a consultation with Doctor #{doctor.id} on #{appointment_date}."
#       end

#       if existing_consultation_same_time
#         puts "Appointment time #{appointment_time} already booked with Doctor #{doctor.id}."
#       end

#       # Generate a new appointment time and randomly select a different patient
#       appointment_time = generate_random_appointment_time
#       appointment_date = appointment_time.to_date  # Update appointment_date
#       patient = patients.sample  # Select a new random patient

#       # Re-check for conflicts with the new values
#       existing_consultation_same_day = Consultation.find_by(doctor: doctor, patient: patient, appointment: appointment_date.all_day)
#       existing_consultation_same_time = Consultation.find_by(doctor: doctor, appointment: appointment_time)
#     end

#     # After resolving conflicts, create the consultation
#     consultation = Consultation.create!(
#       appointment: appointment_time,
#       status: Consultation.statuses.keys.sample,  # Randomly assign a status
#       doctor: doctor,
#       patient: patient,
#       is_archived: false,
#       refus_reason: [nil, Faker::Lorem.sentence].sample
#     )
#     puts "Consultation for Patient #{consultation.patient_id} with Doctor #{consultation.doctor_id} seeded."
#   end
# end

########################### Seeding Blogs ##################################

puts "Seeding blogs..."

if doctors.any?
  starting_order = 1

  5.times do |index|
    blog = Blog.create!(
      title: Faker::Lorem.sentence(word_count: 6),
      content: Faker::Lorem.paragraph(sentence_count: 15),
      order: starting_order + index,
      doctor: doctors.sample,
      maladie: Maladie.all.sample
    )

    image_urls = [
      "https://res.cloudinary.com/void-elsan/image/upload/v1668002371/inline-images/Ecz%C3%A9ma.jpg",
      "https://www.dexeryl-gamme.fr/sites/default/files/styles/featured_l_683x683_/public/images/featured/Image1.jpg?h=de238ad2&itok=jFdYeTNh",
      "https://contourderm.com/wp-content/smush-webp/2016/08/leukotam.jpg.webp",
      "https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/SolarAcanthosis.jpg/1200px-SolarAcanthosis.jpg",
      "https://balmonds.com/cdn/shop/articles/Should-Keratosis-Be-Removed.jpg?v=1615555350"
    ]

    [1, 3, 5].sample.times do
      uri = URI.parse(image_urls.sample)
      response = Net::HTTP.get_response(uri)

      if response.is_a?(Net::HTTPSuccess)
        file = StringIO.new(response.body)
        blog.images.attach(io: file, filename: "#{Faker::Lorem.word}.jpg", content_type: response["content-type"])
      else
        puts "Failed to download image for blog titled #{blog.title}"
      end
    end

    puts "Blog titled #{blog.title} seeded."
  end
end

########################### Seeding Holidays ##################################
puts "Seeding holidays 2024..."
# Set up the API endpoint URL
url = URI("https://api.api-ninjas.com/v1/holidays?country=TN&year=2024&type=PUBLIC_HOLIDAY")

# Set up the HTTP request
request = Net::HTTP::Get.new(url)
request["x-API-KEY"] = "mYCPF5Bd6yRjMmCMSGkQnw==6aK6gP1eU5EjzpJw"

# Make the HTTP request and parse the response
response = Net::HTTP.start(url.hostname, url.port, use_ssl: true) do |http|
  http.request(request)
end

# Parse the JSON response
holidays_data = JSON.parse(response.body)
# Seed the holidays table
holidays_data.each do |holiday|
  Holiday.create!(
    holiday_name: holiday["name"],
    holiday_date: holiday["date"],
    is_archived: false
  )
end
puts "Seeding completed! Created #{Holiday.count} holidays."

puts "Seeding holidays 2025..."
# Set up the API endpoint URL
url = URI("https://api.api-ninjas.com/v1/holidays?country=TN&year=2025&type=PUBLIC_HOLIDAY")

# Set up the HTTP request
request = Net::HTTP::Get.new(url)
request["x-API-KEY"] = "mYCPF5Bd6yRjMmCMSGkQnw==6aK6gP1eU5EjzpJw"  # Replace 'YOUR_API_KEY_HERE' with your actual API key

# Make the HTTP request and parse the response
response = Net::HTTP.start(url.hostname, url.port, use_ssl: true) do |http|
  http.request(request)
end

# Parse the JSON response
holidays_data = JSON.parse(response.body)
# Seed the holidays table
holidays_data.each do |holiday|
  Holiday.create!(
    holiday_name: holiday["name"],
    holiday_date: holiday["date"],
    is_archived: false
  )
end
puts "Seeding completed! Created #{Holiday.count} holidays."
puts "Seeding done."
