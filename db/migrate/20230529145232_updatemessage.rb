class Updatemessage < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :sender_id, :uuid
  end
end
