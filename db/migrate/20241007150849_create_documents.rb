class CreateDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :documents, id: :uuid do |t|
      t.string :title
      t.uuid :doctor_id, null: false
      t.boolean :is_archived, :default => false

      t.timestamps
    end
    add_foreign_key :documents, :users, column: :doctor_id

  end
end
