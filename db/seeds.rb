# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
puts "seeding"
Admin.create( 
  email: "Admin@example.com",
  firstname: "Admin",
  lastname:"Admin",
  password: "123456",
  password_confirmation: "123456",
  email_confirmed: true)

Patient.create( 
  email: "patient@example.com",
  firstname: "patient",
  lastname:"patient",
  password: "123456",
  password_confirmation: "123456",
  email_confirmed: true)

Doctor.create(
  email: "doc@example.com",
  password: "123456",
  password_confirmation: "123456",
  lastname: "Smith",
  firstname: "John",
  address: "123 Clinic Rd",
  specialization: "Cardiology",
  latitude: 40.7128,
  longitude: -74.0060,
  email_confirmed: true,
  google_maps_url: "https://maps.google.com/example"
)


# db/seeds.rb

# Clear existing records if needed
#Maladie.destroy_all

# Define file paths for images
def attach_image(maladie, file_path)
  io = File.open(file_path)
  maladie.image.attach(io: io, filename: File.basename(file_path))
end

# Seed data for Maladie
maladies = [
  {
    maladie_name: "Actinic Keratosis",
    maladie_description: "Actinic keratosis is a precancerous skin condition caused by prolonged exposure to ultraviolet (UV) light. It typically appears as a rough, scaly patch on sun-exposed areas of the skin.",
    synonyms: "Solar Keratosis",
    symptoms: "Rough, scaly patches on sun-exposed skin",
    causes: "Prolonged sun exposure",
    treatments: "Cryotherapy, topical treatments",
    prevention: "Avoid excessive sun exposure, use sunscreen",
    diagnosis: "Clinical examination, biopsy",
    references: "https://www.aad.org/public/diseases/a-z/actinic-keratosis",
    image_path: Rails.root.join('app', "assets", "images", 'Actinic Keratosis.png').to_s
  },
  {
    maladie_name: "Basal Cell Carcinoma",
    maladie_description: "Basal cell carcinoma is a type of skin cancer that originates from the basal cells in the epidermis. It is the most common form of skin cancer and typically presents as a small, shiny bump or a sore that doesn’t heal.",
    synonyms: "BCC",
    symptoms: "Shiny bump, sore that doesn’t heal",
    causes: "Sun exposure, tanning beds",
    treatments: "Surgical removal, topical chemotherapy",
    prevention: "Use sunscreen, avoid tanning beds",
    diagnosis: "Biopsy, dermoscopy",
    references: "https://www.cancer.org/cancer/basal-cell-carcinoma.html",
    image_path: Rails.root.join('app', "assets", "images", 'Basal cell Carcinoma.png').to_s
  },
  {
    maladie_name: "Benign Keratosis",
    maladie_description: "Benign keratosis refers to a non-cancerous growth on the skin. These can include various types of skin lesions such as seborrheic keratoses, which appear as waxy, raised bumps on the skin.",
    synonyms: "Seborrheic Keratosis",
    symptoms: "Waxy, raised bumps on the skin",
    causes: "Genetics, aging",
    treatments: "Cryotherapy, curettage",
    prevention: "No specific prevention methods",
    diagnosis: "Clinical examination",
    references: "https://www.aad.org/public/diseases/a-z/seborrheic-keratosis",
    image_path: Rails.root.join('app', "assets", "images", 'Benign Keratosis.png').to_s

    
  },
  {
    maladie_name: "Dermatofibroma",
    maladie_description: "Dermatofibroma is a common, benign skin tumor that usually appears as a firm, raised nodule on the skin. It is often brownish in color and may be slightly itchy but is generally harmless.",
    synonyms: "Fibrous Histiocytoma",
    symptoms: "Firm, raised nodule",
    causes: "Unknown, may be related to minor trauma",
    treatments: "Excision if necessary",
    prevention: "No specific prevention methods",
    diagnosis: "Clinical examination, biopsy if needed",
    references: "https://www.aad.org/public/diseases/a-z/dermatofibroma",
    image_path: Rails.root.join('app', "assets", "images", 'Dermatofibroma.png').to_s

  },
  {
    maladie_name: "Melanocytic Nevus",
    maladie_description: "Melanocytic nevus, commonly known as a mole, is a benign growth on the skin that arises from melanocytes (cells that produce pigment). It can vary in color from light brown to black and is typically round or oval in shape.",
    synonyms: "Mole",
    symptoms: "Pigmented spot or mole",
    causes: "Genetics, sun exposure",
    treatments: "Monitor for changes, excision if needed",
    prevention: "Regular skin checks, avoid excessive sun exposure",
    diagnosis: "Clinical examination, dermoscopy",
    references: "https://www.cancer.org/cancer/melanoma-skin-cancer/about/melanocytic-nevi.html",
    image_path: Rails.root.join('app', "assets", "images", 'Melanocytic Nevus.png').to_s

  },
  {
    maladie_name: "Melanoma",
    maladie_description: "Melanoma is a serious form of skin cancer that originates in the melanocytes. It often appears as a new or changing mole or pigmented spot on the skin and can be life-threatening if not treated early.",
    synonyms: "Malignant Melanoma",
    symptoms: "New or changing mole, asymmetry, irregular borders",
    causes: "UV radiation, genetic factors",
    treatments: "Surgical removal, chemotherapy, immunotherapy",
    prevention: "Avoid sunburn, use sunscreen",
    diagnosis: "Biopsy, imaging tests",
    references: "https://www.cancer.org/cancer/melanoma.html",
    image_path: Rails.root.join('app', "assets", "images", 'Melanoma.png').to_s

  },
  {
    maladie_name: "Squamous Cell Carcinoma",
    maladie_description: "Squamous cell carcinoma is a type of skin cancer that originates from squamous cells in the epidermis. It can appear as a red, scaly patch or a sore that doesn’t heal and may spread if not treated promptly.",
    synonyms: "SCC",
    symptoms: "Red, scaly patch, sore that doesn’t heal",
    causes: "Sun exposure, chronic irritation",
    treatments: "Surgical removal, radiation therapy",
    prevention: "Use sunscreen, avoid sun exposure",
    diagnosis: "Biopsy, clinical examination",
    references: "https://www.cancer.org/cancer/squamous-cell-carcinoma.html",
    image_path: Rails.root.join('app', "assets", "images", 'Squamous Cell Carcinoma.png').to_s

  },
  {
    maladie_name: "Vascular Lesion",
    maladie_description: "Vascular lesions are abnormal growths or malformations of blood vessels in the skin or other tissues. They can include conditions such as hemangiomas, port-wine stains, and telangiectasias, and may appear as red or purple spots on the skin.",
    synonyms: "Vascular Malformations",
    symptoms: "Red or purple spots or lesions",
    causes: "Congenital, sometimes associated with other conditions",
    treatments: "Laser therapy, surgical removal",
    prevention: "No specific prevention methods",
    diagnosis: "Clinical examination, imaging if needed",
    references: "https://www.aad.org/public/diseases/a-z/vascular-lesions",
    image_path: Rails.root.join('app', "assets", "images", 'Vascular Lesion.png').to_s

  }
]

# Create records and attach images
maladies.each do |maladie_data|
  maladie = Maladie.find_by(maladie_name: maladie_data[:maladie_name])
  
  unless maladie
    maladie = Maladie.create(
      maladie_name: maladie_data[:maladie_name],
      maladie_description: maladie_data[:maladie_description],
      synonyms: maladie_data[:synonyms],
      symptoms: maladie_data[:symptoms],
      causes: maladie_data[:causes],
      treatments: maladie_data[:treatments],
      prevention: maladie_data[:prevention],
      diagnosis: maladie_data[:diagnosis],
      references: maladie_data[:references]
    )
    attach_image(maladie, maladie_data[:image_path]) if maladie_data[:image_path]
  end
end

puts "seeding done"