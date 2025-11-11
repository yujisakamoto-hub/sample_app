require "test_helper"

class PasswordResets < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end
end

class ForgotPasswordFormTest < PasswordResets

  test "パスワードリセットへのアクセス" do
    get new_password_reset_path
    assert_template "password_resets/new"
    assert_select "input[name=?]", "password_reset[email]"
  end

  test "無効なメールアドレスでパスワードリセットしようとした場合" do
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_response :unprocessable_content
    assert_not flash.empty?
    assert_template "password_resets/new"
  end
end

class PasswordResetForm < PasswordResets

  def setup
    super
    @user = users(:michael)
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
  end
end

class PasswordFormTest < PasswordResetForm

  test "有効なメールアドレスの場合" do
    assert_not_equal @user.reset_digest, @reset_user.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "無効なメールアドレスの場合" do
    get edit_password_reset_path(@reset_user.reset_token, email: "")
    assert_redirected_to root_url
  end

  test "有効化されていないユーザーの場合" do
    @reset_user.toggle!(:activated)
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_redirected_to root_url
  end

  test "メールアドレスは正しいが、トークンが正しくない場合" do
    get edit_password_reset_path("wrong token", email: @reset_user.email)
    assert_redirected_to root_url
  end

  test "メールアドレス、トークンともに正しい場合" do
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_template "password_resets/edit"
    assert_select "input[name=email][type=hidden][value=?]", @reset_user.email
  end
end

class PasswordUpdateTest < PasswordResetForm

  test "無効なパスワード、確認の場合" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobazsdfs",
                            password_confirmation: "barquuxssfs" } }
    assert_select "div#error_explanation"
  end

  test "空で送信した場合" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:      "",
                    password_confirmation: "" } }
    assert_select "div#error_explanation"
  end

  test "正しく入力した場合" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "password",
                            password_confirmation: "password" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to @reset_user
    assert_nil @reset_user.reload.reset_digest
  end
end

class ExpiredToken < PasswordResets
  
  def setup
    super
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
    @reset_user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "password",
                            password_confirmation: "password" } }
  end
end

class ExpiredTokenTest < ExpiredToken

  test "トークン期限切れの場合new/password_resetにリダイレクトされる" do
    assert_redirected_to new_password_reset_url
  end

  test "リダイレクト先に'expired'の文字列が含まれているか" do
    follow_redirect!
    assert_match /パスワード再設定期限が切れました/i, response.body
  end
end
