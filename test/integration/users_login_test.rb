require "test_helper"

class UsersLogin < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end
end

class InvalidPasswordTest < UsersLogin

  test "login pathに飛べるかテスト" do
    get login_path
    assert_template 'sessions/new'
  end

  test "メーリアドレスは正しく、パスワードは誤っているパターンのテスト" do
    post login_path, params: { session: { email:    @user.email,
                                          password: "invalid" } }
    assert_not is_logged_in?
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
end

class ValidLogin < UsersLogin

  def setup
    super
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
  end
end

class ValidLoginTest < ValidLogin

  test "ログイン成功しているかのテスト" do
    assert is_logged_in?
    assert_redirected_to @user
  end

  test "ログイン後のリダイレクトが正しいかのテスト" do
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end
end

class Logout < ValidLogin

  def setup
    super
    delete logout_path
  end
end

class LogoutTest < Logout

  test "ログアウトできているかのテスト" do
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
  end

  test "ログアウト後のリダイレクトが正しいかのテスト" do
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "2番目のウィンドウでログアウトした場合のテスト" do
    delete logout_path
    assert_redirected_to root_path
  end
end

class RememberingTest < UsersLogin
  test "ログイン保持のパターン" do
    log_in_as(@user, remember_me: "1")
    assert_equal cookies[:remember_token], assigns(:user).remember_token
  end

  test "ログイン保持しないパターン" do
    log_in_as(@user, remember_me: "1")
    log_in_as(@user, remember_me: "0")
    assert cookies[:remember_token],blank?
  end
end

class FriendlyForwardingTest < UsersLogin
  test "フレンドリーフォワーディングテスト" do
    #ログインせずに保護ページにアクセス
    get edit_user_path(@user)

    #セッションにURLが保存されていることを確認
    assert_equal session[:forwarding_url], edit_user_url(@user)

    #ログイン
    log_in_as(@user)

    #最初のログイン後は保存されたURLにリダイレクトされる
    assert_redirected_to edit_user_url(@user)

    #一度ログアウト
    delete logout_path

    #再度ログイン
    log_in_as(@user)

    #デフォルトURLにリダイレクトされることを確認
    assert_redirected_to @user
  end
end
