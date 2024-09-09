class CreateUserSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :user_settings, id: :uuid do |t|
      t.boolean :is_emailable, default: true
      t.boolean :is_notifiable, default: true
      t.boolean :is_smsable, default: true
      t.boolean  :is_archived, :default => false
      t.references :user,type: :uuid,  null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
