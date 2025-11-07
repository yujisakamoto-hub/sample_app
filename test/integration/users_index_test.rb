require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
    @user = users(:michael)
  end

  test "indexにpaginationが有効かどうか" do
    log_in_as(@user)
    get users_path
    assert_template "users/index"
    assert_select "ul.pagination", count: 2
    User.paginate(page: 1, per_page: 30).each do |user|
      assert_select "a[href=?]", user_path(user), text: user.name
    end
  end
end
