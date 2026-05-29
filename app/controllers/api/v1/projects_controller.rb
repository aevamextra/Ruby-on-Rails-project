module Api
  module V1
    class ProjectsController < BaseController
      before_action :set_project, only: :show

      def index
        projects = current_user.projects.includes(:tasks)

        render json: {
          data: projects.map { |project| serialize_project(project) },
          meta: { count: projects.count }
        }
      end

      def show
        render json: { data: serialize_project(@project) }
      end

      def create
        project = current_user.projects.build(project_params)

        if project.save
          render json: { data: serialize_project(project) }, status: :created, location: api_v1_project_url(project)
        else
          render_validation_errors(project)
        end
      end

      private

      def set_project
        @project = current_user.projects.includes(:tasks).find(params.expect(:id))
      end

      def project_params
        params.expect(project: [ :name, :description ])
      end

      def serialize_project(project)
        {
          id: project.id.to_s,
          type: "projects",
          attributes: {
            name: project.name,
            description: project.description,
            created_at: project.created_at,
            updated_at: project.updated_at
          },
          relationships: {
            tasks: {
              data: project.tasks.map { |task| { type: "tasks", id: task.id.to_s } }
            }
          }
        }
      end
    end
  end
end
