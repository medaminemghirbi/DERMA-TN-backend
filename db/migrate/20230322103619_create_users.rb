class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid  do |t|
      t.string :email
      t.string :password_digest
      t.string :firstname
      t.string :lastname
      t.string :address
      t.boolean :email_confirmed, :default => false
      t.string :confirm_token
      t.string :password_reset_token
      t.datetime :password_reset_sent_at
      t.bigint :phone_number
      t.date :birthday
      t.string :gender
      t.integer :civil_status
      t.boolean  :is_archived, :default => false
      # Add this column for STI
      t.string :type
      # Add Doctor-specific fields
      t.string :location
      t.string :specialization
      t.float :latitude
      t.float :longitude
      t.string :google_maps_url
      t.string :description
      #Add  Patient-specific fields

      t.string :medical_history
      t.timestamps

    end
  end
end
