class TasksController < ApplicationController
  before_action :require_login
  before_action :set_task, only: %i[ show edit update destroy ]
  before_action :authorize_owner!, only: %i[ edit update destroy ]

  # GET /tasks or /tasks.json
  def index
    @tasks = current_user.tasks

    # Pagination logic
    if params[:search].present?
      @tasks = @tasks.where("title LIKE ? OR description LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:status].present?
      @tasks = @tasks.where(status: Task.statuses[params[:status]])
    end


    if params[:priority].present?
    @tasks = @tasks.where(priority: Task.priorities[params[:priority]])
    end
    
    if params[:sort] == "priority_asc"
     @tasks = @tasks.order(priority: :asc)
    elsif params[:sort] == "priority_desc"
     @tasks = @tasks.order(priority: :desc)
    end

    @tasklength = @tasks.length
    @currentPage = (params[:page] || 1).to_i
    @tasks_per_page = 5
    @numberOfPage = (@tasklength / @tasks_per_page.to_f).ceil

    # Use offset & limit for proper pagination
    @tasks = @tasks.offset((@currentPage - 1) * @tasks_per_page).limit(@tasks_per_page)
  end

  # GET /tasks/1 or /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks or /tasks.json
  def create
    @task = current_user.tasks.build(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: "Task was successfully created." }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1 or /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task, notice: "Task was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1 or /tasks/1.json
  def destroy
    @task.destroy!

    respond_to do |format|
      format.html { redirect_to tasks_path, notice: "Task was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def authorize_owner!
      unless @task.user_id == current_user.id
        redirect_to tasks_path, alert: "Not authorized to modify this task."
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.expect(task: [ :title, :description, :status, :priority ])
    end
    
end
