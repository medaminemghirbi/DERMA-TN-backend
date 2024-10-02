class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications, id: :uuid do |t|
      t.uuid :consultation_id
      t.string :status
      t.datetime :received_at

      t.timestamps
    end
    add_index :notifications, :consultation_id
  end
end
