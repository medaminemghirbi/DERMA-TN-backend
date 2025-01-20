class Api::V1::BlogReactionsController < ApplicationController
    def create
      blog = Blog.find(params[:blog_id])
      user = User.find(params[:user_id]) # Find the User object
      reaction = params[:reaction] # 'like' or 'dislike'
  
      blog_reaction = BlogReaction.find_or_initialize_by(user: user, blog: blog) # Use the User object
  
      # Check if the user is repeating the same reaction
      if blog_reaction.persisted? && blog_reaction.reaction == reaction
        render json: { message: "You already #{reaction}d this post!" }, status: :unprocessable_entity
        return
      end
  
      # Update the reaction
      blog_reaction.reaction = reaction
  
      if blog_reaction.save
        render json: { 
          message: "Reaction saved!", 
          likes: blog.likes_count, 
          dislikes: blog.dislikes_count 
        }, status: :ok
      else
        render json: { errors: blog_reaction.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
  