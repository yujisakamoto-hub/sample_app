class PasswordResetsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "パスワードリセット手順が記載されたメールを送信しました"
      redirect_to root_url
    else
      flash[:danger] = "このメールアドレスは登録されていません"
      render "new", status: :unprocessable_content
    end
  end

  def edit
  end
end
