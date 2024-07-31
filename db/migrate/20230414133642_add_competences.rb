class AddCompetences < ActiveRecord::Migration[7.0]
  def change
    create_table :competences, id: :uuid do |t|
      t.references :user , null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.references :souscategorie , null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.integer :niveau
      t.timestamps
    end
  end
end
