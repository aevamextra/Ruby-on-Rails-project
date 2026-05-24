class ProjectsController < ApplicationController
  before_action :require_login
  before_action :set_project, only: %i[ show edit update destroy ]

  # GET /projects or /projects.json
  def index
    @projects = current_user.projects
  end

  # GET /projects/1 or /projects/1.json
  def show
    @tasks = @project.tasks
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
    @tasks = @tasks.offset((@currentPage - 1) * @tasks_per_page).limit(@tasks_per_page)
  end

  # GET /projects/new
  def new
    @project = current_user.projects.build
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects or /projects.json
  def create
    @project = current_user.projects.build(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: "Project was successfully created." }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1 or /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: "Project was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1 or /projects/1.json
  def destroy
    @project.destroy!

    respond_to do |format|
      format.html { redirect_to projects_path, notice: "Project was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = current_user.projects.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.expect(project: [ :name, :description ])
    end
end
