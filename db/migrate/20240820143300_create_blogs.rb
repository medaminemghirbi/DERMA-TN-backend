class CreateBlogs < ActiveRecord::Migration[7.0]
  def change
    create_table :blogs, id: :uuid do |t|
      t.string :title
      t.text :content
      t.references :user, type: :uuid, null: false, foreign_key: { to_table: :users } # Associate blog with a user (doctor)

      t.timestamps
    end
  end
end
