class CreateConsultations < ActiveRecord::Migration[7.0]
  def change
    create_table :consultations, id: :uuid do |t|
      t.datetime :appointment, null: false   # Store both date and time
      t.integer :status, default: 0
      t.boolean :is_archived, default: false
      t.uuid :doctor_id, null: false
      t.uuid :patient_id, null: false
      t.string :refus_reason
      t.timestamps
    end
    
    add_index :consultations, :patient_id
    add_index :consultations, :appointment
    add_index :consultations, [:appointment, :patient_id], unique: true, name: 'index_consultations_on_appointment_and_patient_id'
    
    add_foreign_key :consultations, :users, column: :doctor_id
    add_foreign_key :consultations, :users, column: :patient_id
  end
end
