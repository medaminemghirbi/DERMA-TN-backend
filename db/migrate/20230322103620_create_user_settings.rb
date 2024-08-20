class CreateUserSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :user_settings, id: :uuid do |t|
      t.boolean :is_emailable, default: true
      t.boolean :is_notifiable, default: true
      t.boolean :is_smsable, default: true
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end
