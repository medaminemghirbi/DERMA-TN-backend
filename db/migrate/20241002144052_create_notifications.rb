class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications, id: :uuid do |t|
      t.uuid :doctor_id
      t.uuid :patient_id
      t.string :status
      t.datetime :received_at
      t.integer :order, default: 1

      t.timestamps
    end
  end
end
