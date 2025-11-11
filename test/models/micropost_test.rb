require "test_helper"

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: "test")
  end

  test "有効かどうかチェック" do
    assert @micropost.valid?
  end

  test "user_idがなければならない" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "contentは存在しなければならない" do
    @micropost.content = "    "
    assert_not @micropost.valid?
  end

  test "contentは140字以内でなければならない" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  test "最新の順に並べられているか" do
    assert_equal microposts(:most_recent), Micropost.first
  end
end
