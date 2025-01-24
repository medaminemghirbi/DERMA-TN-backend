class CreateBlogReactions < ActiveRecord::Migration[7.0]
  def change
    create_table :blog_reactions, id: :uuid do |t|
      t.uuid "user_id", null: false       # Reference to the user who reacted
      t.uuid "blog_id", null: false       # Reference to the blog being reacted to
      t.string "reaction", null: false    # 'like' or 'dislike'        
      t.timestamps
      t.index ["user_id", "blog_id"], unique: true  # Ensures a user reacts to a blog only once

    end
  end
end
