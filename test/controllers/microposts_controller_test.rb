require "test_helper"

class MicropostsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @micropost = microposts(:orange)
  end

  test "ログインしないと投稿できない" do
    assert_no_difference "Micropost.count" do
      post microposts_path, params: { micropost: { content: "test" } }
    end
    assert_redirected_to login_url
  end

  test "ログインしないと投稿削除できない" do
    assert_no_difference "Micropost.count" do
      delete micropost_path(@micropost)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test "自分以外のユーザーが投稿したマイクロポストは削除できない" do
    log_in_as(users(:michael))
    micropost = microposts(:ants)
    assert_no_difference "Micropost.count" do
      delete micropost_path(micropost)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end
end
