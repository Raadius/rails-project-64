class PostsController < ApplicationController
  before_action :find_post, only: %i[ show ]

  # GET /posts
  def index
    @posts = Post.includes(:creator, :category).all
  end

  # GET /posts/1
  def show
    @post = find_post
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # POST /posts
  def create
    @post = Post.new(post_params)
    @post.creator = current_user

    if @post.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity, notice: t('post.new.notice.failed')
    end
  end

  private
    def find_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:title, :body, :category_id)
    end
end
