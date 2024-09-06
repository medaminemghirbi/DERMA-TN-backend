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
      phone_number: rand(1_000_000..99_999_999).to_s.rjust(8, '0'),

      email_confirmed: true
    )
    downloaded_image = URI.open(Faker::Avatar.image)
    patient.avatar.attach(io: downloaded_image, filename: "#{patient.firstname}_avatar.jpg", content_type: 'image/jpg')
    puts "Created patient: #{patient.firstname} #{patient.lastname} (#{patient.email})"
  end

    
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


  puts "fake consutlation"
  patients = Patient.all
  doctors = Doctor.all

# Ensure there are patients and doctors in the database
  if patients.empty? || doctors.empty?
    puts "No patients or doctors found in the database. Please create some first."
  else
    # Generate consultations
    2000.times do
      # Randomly select a patient and doctor
      patient = patients.sample
      doctor = doctors.sample

      # Generate a random appointment time in the future
      appointment_time = Faker::Time.forward(days: 30, period: :evening)

      # Create the consultation record
      consultation = Consultation.create(
        appointment: appointment_time,
        status: rand(0..2), # Assuming status is an integer where 0, 1, 2 represent different statuses
        is_archived: [true, false].sample,
        doctor_id: doctor.id,
        patient_id: patient.id,
        refus_reason: [nil, Faker::Lorem.sentence].sample # Random refusal reason or nil
      )

      puts "Created consultation for Patient ID: #{patient.id} with Doctor ID: #{doctor.id} on #{consultation.appointment}"
    end

    puts "seeding done"
  end

  puts "Seeding blogs..."

  # Make sure you have some doctors in your database first
  doctors = Doctor.all
  starting_order = 1

  if doctors.any?
    10.times do |index|

      blog = Blog.new(
        title: Faker::Lorem.sentence(word_count: 6),
        content: Faker::Lorem.paragraph(sentence_count: 15),
        order: starting_order + index, # Incremental order value
        doctor: doctors.sample
      )

      # Determine a random number of images (1, 3, or 5)
      number_of_images = [1, 3, 5].sample

      # Example image URLs from the internet (you can replace these with actual URLs)
      image_urls = [
        'https://res.cloudinary.com/void-elsan/image/upload/v1668002371/inline-images/Ecz%C3%A9ma.jpg',
        'https://www.dexeryl-gamme.fr/sites/default/files/styles/featured_l_683x683_/public/images/featured/Image1.jpg?h=de238ad2&itok=jFdYeTNh',
        'https://contourderm.com/wp-content/smush-webp/2016/08/leukotam.jpg.webp',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/SolarAcanthosis.jpg/1200px-SolarAcanthosis.jpg',
        'https://balmonds.com/cdn/shop/articles/Should-Keratosis-Be-Removed.jpg?v=1615555350'
      ]

      # Attach the selected number of images to the blog
      number_of_images.times do
        random_url = image_urls.sample
        file = URI.open(random_url)
        blog.images.attach(io: file, filename: "#{Faker::Lorem.word}.jpg")
      end

      blog.save!
    end
  else
    puts "No doctors found. Please seed doctors first."
  end

  puts "Blogs seeded successfully!"

  blogs = Blog.current

# Define a list of example messages
messages_content = [
  "This is a great blog post!",
  "I found this information very helpful.",
  "Thanks for sharing this valuable content.",
  "This is really insightful. I learned a lot.",
  "Great read! I appreciate the detailed explanation."
]

blogs.each do |blog|
  random_messages = messages_content.sample(3)

  random_messages.each do |message_body|
    Message.create!(
      body: message_body,
      sender: User.all.sample
      )
  end
end

puts "Messages created for all blogs."
end
