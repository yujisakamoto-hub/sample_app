require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "sign_upページへのアクセステスト" do
    get signup_path
    assert_response :success
  end

  test "ログインしていない場合はeditにアクセスしようとしてもリダイレクトされる" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "ログインしていない場合はupdateしようとしてもリダイレクトされる" do
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "別のユーザーのeditはできない" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "別のユーザーのupdateはできない" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "ログインしないとindexにアクセスできない" do
    get users_path
    assert_redirected_to login_url
  end

  test "admin属性をweb経由で編集できない" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: { user: { password: "password",
                                                    password_confirmation: "password",
                                                    admin: true } }
    assert_not @other_user.reload.admin?
  end

  test "ログインしていない場合ユーザー削除できない" do
    assert_no_difference "User.count" do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test "管理者ではない場合ユーザー削除できない" do
    log_in_as(@other_user)
    assert_no_difference "User.count" do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end
end
