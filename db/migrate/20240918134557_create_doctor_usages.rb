class CreateDoctorUsages < ActiveRecord::Migration[7.0]
  def change
    create_table :doctor_usages, id: :uuid do |t|
      t.uuid :doctor_id, null: false
      t.integer :count, default: 0
      t.boolean :is_archived, :default => false
    end
    add_foreign_key :doctor_usages, :users, column: :doctor_id
  end
end
