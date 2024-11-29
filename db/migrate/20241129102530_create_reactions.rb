class CreateReactions < ActiveRecord::Migration[7.0]
  def change
    create_table :reactions, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :blog, null: false, foreign_key: true, type: :uuid
      t.integer :reaction_type

      t.timestamps
    end
  end
end
