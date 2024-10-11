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
      t.date :birthday
      t.integer :gender
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
      t.string   :code_doc
      t.string :website
      t.string :twitter
      t.string :youtube
      t.string :facebook
      t.string :linkedin
      t.string :phone_number
      #Add  Patient-specific fields

      t.string :medical_history
      t.integer :plan, default: 0
      t.integer :custom_limit, default: 0

      #Add User Settings to avoid tables
      t.boolean :is_emailable, default: true
      t.boolean :is_notifiable, default: true
      t.boolean :is_smsable, default: true
      t.boolean :working_saturday, :default => false

      t.timestamps

    end
  end
end
