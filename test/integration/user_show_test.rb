require "test_helper"

class UserShowTest < ActionDispatch::IntegrationTest

  def setup
    @inactive_user  = users(:inactive)
    @activated_user = users(:archer)
  end

  test "有効化されていないユーザーの詳細ページにアクセスするとリダイレクトされる" do
    get user_path(@inactive_user)
    assert_response :redirect
    assert_redirected_to root_url
  end

  test "有効化されているユーザーの詳細ページにはアクセスできる" do
    get user_path(@activated_user)
    assert_response :success
    assert_template "users/show"
  end
end
