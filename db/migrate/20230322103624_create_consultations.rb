class CreateConsultations < ActiveRecord::Migration[7.0]
  def change
    create_table :consultations, id: :uuid do |t|
      t.datetime :appointment, null: false
      t.integer :status, default: 0
      t.boolean :is_archived, default: false
      t.uuid :doctor_id, null: false
      t.uuid :patient_id, null: false
      t.string :refus_reason
      t.timestamps
    end
    add_foreign_key :consultations, :users, column: :doctor_id
    add_foreign_key :consultations, :users, column: :patient_id
  end
end
