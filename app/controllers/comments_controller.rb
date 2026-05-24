class CommentsController < ApplicationController
  before_action :require_login

  def create
    @task = Task.find(params[:task_id])
    @comment = @task.comments.build(comment_params)
    @comment.user = current_user
    
    if @comment.save
      redirect_to @task, notice: "Comment added!"
    else
      redirect_to @task, alert: "Comment could not be added."
    end
  end

  def destroy
    @task = Task.find(params[:task_id])
    @comment = @task.comments.find(params[:id])
    
    if @comment.user == current_user || @task.user == current_user
      @comment.destroy
      redirect_to @task, notice: "Comment deleted."
    else
      redirect_to @task, alert: "Not authorized to delete this comment."
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
