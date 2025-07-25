class HomeController < ApplicationController
  def index
    @posts = Post.includes(:creator, :category).all
  end
end
