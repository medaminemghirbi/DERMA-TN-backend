class Api::V1::Web::BlogsController < ApplicationController
  before_action :set_blog, only: [:show, :update, :destroy]
  before_action :authorize_request

  # GET /api/v1/blogs
  def index
    @blogs = Blog.all
    render json: @blogs, include: [:images]
  end

  # GET /api/v1/blogs/:id
  def show
    render json: @blog, include: [:images]
  end

  # POST /api/v1/blogs
  def create
    @blog = current_user.blogs.build(blog_params)

    if @blog.save
      render json: @blog, status: :created, location: api_v1_blog_url(@blog)
    else
      render json: @blog.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/blogs/:id
  def update
    if @blog.update(blog_params)
      render json: @blog
    else
      render json: @blog.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/blogs/:id
  def destroy
    @blog.destroy
    head :no_content
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    params.permit(:title, :content, :docteur_id, images: [] )
  end

end
