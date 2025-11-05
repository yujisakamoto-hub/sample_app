require "test_helper"

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:michael)
    remember(@user)
  end

  test "current_user はセッションが nil の場合に正しいユーザーを返す" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  test "remember_digestが間違っている場合、current_userはnilを返す" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end
