require "test_helper"

class Api::V1::ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @project = projects(:one)
  end

  test "unauthenticated request is blocked" do
    get api_v1_projects_url, as: :json

    assert_redirected_to login_url
  end

  test "index returns only current user projects" do
    sign_in_as(@user)

    get api_v1_projects_url, as: :json
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.headers["Content-Type"]

    body = JSON.parse(response.body)
    assert_equal 1, body["meta"]["count"]
    assert_equal @project.id.to_s, body["data"].first["id"]
    assert_equal "projects", body["data"].first["type"]
  end

  test "show returns owned project and hides non-owned project" do
    sign_in_as(@user)

    get api_v1_project_url(@project), as: :json
    assert_response :success

    get api_v1_project_url(projects(:two)), as: :json
    assert_response :not_found
  end

  test "create succeeds and ignores mass assignment for user_id" do
    sign_in_as(@user)

    assert_difference("Project.count", 1) do
      post api_v1_projects_url, params: {
        project: {
          name: "API Project",
          description: "Created via API",
          user_id: @other_user.id
        }
      }, as: :json
    end

    assert_response :created
    assert_not_nil response.headers["Location"]
    created_project = Project.order(:id).last
    assert_equal @user.id, created_project.user_id
  end

  test "create returns jsonapi errors for invalid payload" do
    sign_in_as(@user)

    assert_no_difference("Project.count") do
      post api_v1_projects_url, params: {
        project: { name: "", description: "No name" }
      }, as: :json
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert body["errors"].is_a?(Array)
    assert_equal "422", body["errors"].first["status"]
  end
end
