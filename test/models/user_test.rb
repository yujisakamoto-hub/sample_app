require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  TEST_PASSWORD = "xanavi2008"

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "#{TEST_PASSWORD}", password_confirmation: "#{TEST_PASSWORD}")
  end

  test "ユーザーが有効かどうかのテスト" do
    assert @user.valid?
  end

  test "nameの文字数制限のテスト" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "emailの文字数制限のテスト" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "有効なメールアドレスのテスト" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp 
                         alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "無効なメールアドレスのテスト" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.foo@bar_baz.com
                           foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "emailの一意性テスト" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "emailが小文字で保存されているかのテスト" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "passwordが空白だった場合のテスト" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "passwordの文字数が足りない場合のテスト" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "ダイジェストが存在しない場合のauthenticated?のテスト" do
    assert_not @user.authenticated?(:remember, "")
  end
end
