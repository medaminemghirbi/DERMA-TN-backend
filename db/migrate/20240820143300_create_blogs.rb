class CreateBlogs < ActiveRecord::Migration[7.0]
  def change
    create_table :blogs, id: :uuid do |t|
      t.string :title
      t.text :content
      t.uuid :doctor_id, null: false
      t.boolean  :is_archived, :default => false
      t.boolean :is_verified, :default => false
      t.integer :order, :default => 1
      t.timestamps
    end
  end
  execute("CREATE SEQUENCE blogs_order_seq START 1")
  change_column_default :blogs, :order, -> { "nextval('blogs_order_seq')" }

end
