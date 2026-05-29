module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session
      before_action :require_login

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActionController::ParameterMissing, with: :parameter_missing

      private

      def record_not_found
        render_jsonapi_error(status: :not_found, title: "Not Found", detail: "Record not found")
      end

      def parameter_missing(error)
        render_jsonapi_error(
          status: :unprocessable_entity,
          title: "Invalid Request",
          detail: error.message
        )
      end

      def render_jsonapi_errors(errors, status:)
        render json: { errors: }, status:
      end

      def render_jsonapi_error(status:, title:, detail:, source: nil)
        error = {
          status: Rack::Utils::SYMBOL_TO_STATUS_CODE[status].to_s,
          title:,
          detail:
        }
        error[:source] = source if source.present?
        render_jsonapi_errors([ error ], status:)
      end

      def render_validation_errors(record)
        errors = record.errors.map do |error|
          payload = {
            status: "422",
            title: "Validation Error",
            detail: error.full_message
          }
          payload[:source] = { pointer: "/data/attributes/#{error.attribute}" } if error.attribute.present?
          payload
        end

        render_jsonapi_errors(errors, status: :unprocessable_entity)
      end
    end
  end
end
