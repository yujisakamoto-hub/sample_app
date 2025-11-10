require "test_helper"

class UsersIndex < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end
end

class UsersIndexAdmin < UsersIndex

  def setup
    super
    log_in_as(@admin)
    get users_path
  end
end

class UsersIndexAdminTest < UsersIndexAdmin

  test "管理者はusers/indexにアクセスできる" do
    assert_template "users/index"
  end

  test "ページネーションが機能しているか" do
    assert_select "ul.pagination", count: 2
  end

  test "管理者にはdeleteリンクが表示される" do
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select "a[href=?]", user_path(user), text: user.name
      unless user == @admin
        assert_select "a[href=?]", user_path(user), text: "delete"
      end
    end
  end

  test "管理者はユーザーを削除できる" do
    assert_difference "User.count", -1 do
      delete user_path(@non_admin)
    end
    assert_response :see_other
    assert_redirected_to users_url
  end

  test "users/indexには有効化されたユーザーのみが表示される" do
    User.paginate(page: 1).first.toggle!(:activated)
    get users_path
    assigns(:users).each do |user|
      assert user.activated?
    end
  end
end

class UsersNonAdminIndexTest < UsersIndex

  test "管理者以外がindexにアクセスしたときのテスト" do
    log_in_as(@non_admin)
    get users_path
    assert_select "a", text: "delete", count: 0
  end
end
