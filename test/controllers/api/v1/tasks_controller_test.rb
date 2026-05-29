require "test_helper"

class Api::V1::TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @task = tasks(:one)
  end

  test "unauthenticated request is blocked" do
    get api_v1_tasks_url, as: :json

    assert_redirected_to login_url
  end

  test "index returns only current user tasks" do
    sign_in_as(@user)

    get api_v1_tasks_url, as: :json
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.headers["Content-Type"]

    body = JSON.parse(response.body)
    assert_equal 1, body["meta"]["count"]
    assert_equal @task.id.to_s, body["data"].first["id"]
    assert_equal "tasks", body["data"].first["type"]
  end

  test "show returns owned task and hides non-owned task" do
    sign_in_as(@user)

    get api_v1_task_url(@task), as: :json
    assert_response :success

    get api_v1_task_url(tasks(:two)), as: :json
    assert_response :not_found
  end

  test "create succeeds and ignores mass assignment for user_id" do
    sign_in_as(@user)

    assert_difference("Task.count", 1) do
      post api_v1_tasks_url, params: {
        task: {
          title: "API created task",
          description: "Created via API",
          status: "inprogress",
          priority: "medium",
          user_id: @other_user.id
        }
      }, as: :json
    end

    assert_response :created
    assert_not_nil response.headers["Location"]
    created_task = Task.order(:id).last
    assert_equal @user.id, created_task.user_id
  end

  test "create rejects project_id owned by another user" do
    sign_in_as(@user)

    assert_no_difference("Task.count") do
      post api_v1_tasks_url, params: {
        task: {
          title: "Invalid project assignment",
          description: "Should fail",
          status: "done",
          priority: "high",
          project_id: projects(:two).id
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_equal "422", body["errors"].first["status"]
  end

  test "create returns jsonapi errors for invalid payload" do
    sign_in_as(@user)

    assert_no_difference("Task.count") do
      post api_v1_tasks_url, params: {
        task: {
          title: "",
          description: "",
          status: "done",
          priority: "high"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert body["errors"].is_a?(Array)
    assert_equal "422", body["errors"].first["status"]
  end
end
