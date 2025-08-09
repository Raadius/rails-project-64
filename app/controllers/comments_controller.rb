# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :authenticate_user!, except: %i[show]
  before_action :set_post
  before_action :set_comment, only: %i[show destroy]
  def show
    @comment_subtree = @comment.subtree.arrange
    respond_to do |format|
      format.html { redirect_to @post }
      format.turbo_stream
    end
  end

  # POST /posts/:post_id/post_comments
  def create
    @comment = @post.post_comments.build(comment_params)
    @comment.user = current_user

    if @comment.parent_id.present?
      parent_comment = @post.post_comments.find(@comment.parent_id)
      @comment.parent = parent_comment
    end

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @post, notice: I18n.t('comments.actions.create_successfully') }
      else
        format.html { render 'posts/show', status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if can_delete_comment?
      @comment.destroy
      respond_to do |format|
        format.html { redirect_to @post, notice: I18n.t('comments.actions.deleted_successfully') }
      end
    else
      respond_to do |format|
        format.html { redirect_to @post, alert: I18n.t('comments.actions.deleted_failed') }
      end
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.post_comments.find(params[:id])
  end

  def comment_params
    params.require(:post_comment).permit(:content, :parent_id)
  end

  def can_delete_comment?
    @comment.user == current_user
  end
end
