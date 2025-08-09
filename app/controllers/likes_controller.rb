class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    @post.post_likes.create(user: current_user)
    redirect_back(fallback_location: @post)
  end

  def destroy
    @post.post_likes.find_by(user: current_user)&.destroy
    redirect_back(fallback_location: @post)
  end

  private
    def set_post
      @post = Post.find(params[:post_id])
    end
end
