class CreateMaladies < ActiveRecord::Migration[7.0]
  def change
    create_table :maladies, id: :uuid do |t|
      t.string :maladie_name,          null: false
      t.text :maladie_description
      t.text :synonyms
      t.text :symptoms
      t.text :causes
      t.text :treatments
      t.text :prevention
      t.text :diagnosis
      t.text :references

      t.timestamps
    end
  end
end
