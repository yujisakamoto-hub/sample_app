require "test_helper"

class MicropostsInterface < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
    log_in_as(@user)
  end
end

class MicropostsInterfaceTest < MicropostsInterface

  test "ページネーションの存在確認" do
    get root_path
    assert_select "ul.pagination"
  end

  test "投稿が失敗したときのテスト" do
    assert_no_difference "Micropost.count" do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select "div#error_explanation"
    assert_select "a[href=?]", "/?page=2"
  end

  test "投稿が成功したときのテスト" do
    content = "test"
    assert_difference "Micropost.count", 1 do
      post microposts_path, params: { micropost: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
  end

  test "自分の投稿にはdeleteリンクが表示される" do
    get user_path(@user)
    assert_select "a", text: "delete"
  end

  test "自分のマイクロポストを削除できるかテスト" do
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference "Micropost.count", -1 do
      delete micropost_path(first_micropost)
    end
  end

  test "他のユーザーのマイクロポストにはdeleteリンクが表示されない" do
    get user_path(users(:archer))
    assert_select "a", { text: "delete", count: 0 }
  end
end

class MicropostsSidebarTest < MicropostsInterface

  test "複数投稿ある場合のmicroposts.countのテスト" do
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body
  end

  test "投稿が0の場合のmicroposts.countのテスト" do
    log_in_as(users(:malory))
    get root_path
    assert_match "0 microposts", response.body
  end

  test "投稿が1件の場合のmicroposts.countのテスト" do
    log_in_as(users(:lana))
    get root_path
    assert_match "1 micropost", response.body
  end
end
