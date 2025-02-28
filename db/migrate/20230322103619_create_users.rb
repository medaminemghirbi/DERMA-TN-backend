class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email
      t.string :password_digest
      t.string :firstname
      t.string :lastname
      t.string :address
      t.boolean :email_confirmed, default: false
      t.string :confirm_token
      t.string :password_reset_token
      t.datetime :password_reset_sent_at
      t.date :birthday
      t.integer :gender, default: 0
      t.integer :civil_status, default: 0
      t.boolean :is_archived, default: false
      t.integer :order, default: 1
      # Add this column for STI
      t.string :type
      # Add Doctor-specific fields
      t.string :location
      t.string :specialization
      t.float :latitude
      t.float :longitude
      t.string :description
      t.string :code_doc
      t.string :website
      t.string :twitter
      t.string :youtube
      t.string :facebook
      t.string :linkedin
      t.string :phone_number
      # Add  Patient-specific fields

      t.string :medical_history
      t.integer :plan, default: 0
      t.integer :custom_limit, default: 0
      t.integer :radius, default: 1

      # Add User Settings to avoid tables
      t.boolean :is_emailable, default: false
      t.boolean :is_notifiable, default: false
      t.boolean :is_smsable, default: false
      t.boolean :working_saturday, default: false
      t.boolean :working_on_line, default: false
      t.integer :amount
      t.timestamps
    end
  end
end
