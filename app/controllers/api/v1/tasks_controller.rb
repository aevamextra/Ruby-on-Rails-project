module Api
  module V1
    class TasksController < BaseController
      before_action :set_task, only: :show

      def index
        tasks = current_user.tasks.includes(:project)

        render json: {
          data: tasks.map { |task| serialize_task(task) },
          meta: { count: tasks.count }
        }
      end

      def show
        render json: { data: serialize_task(@task) }
      end

      def create
        task = current_user.tasks.build(task_params)

        if task.project_id.present? && !current_user.projects.exists?(id: task.project_id)
          task.errors.add(:project_id, "is invalid for the current user")
          return render_validation_errors(task)
        end

        if task.save
          render json: { data: serialize_task(task) }, status: :created, location: api_v1_task_url(task)
        else
          render_validation_errors(task)
        end
      end

      private

      def set_task
        @task = current_user.tasks.includes(:project).find(params.expect(:id))
      end

      def task_params
        params.expect(task: [ :title, :description, :status, :priority, :project_id ])
      end

      def serialize_task(task)
        {
          id: task.id.to_s,
          type: "tasks",
          attributes: {
            title: task.title,
            description: task.description,
            status: task.status,
            priority: task.priority,
            created_at: task.created_at,
            updated_at: task.updated_at
          },
          relationships: {
            project: {
              data: task.project ? { type: "projects", id: task.project.id.to_s } : nil
            }
          }
        }
      end
    end
  end
end
