class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]

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
      flash.now[:danger] = "このメールアドレスは登録されていません"
      render "new", status: :unprocessable_content
    end
  end

  def edit
  end

  def update
  end

  private #---------------------------------------------------------------------------

    def get_user
      @user = User.find_by(email: params[:email])
    end

    def valid_user
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        flash[:danger] = "無効なユーザーです"
        redirect_to root_url
      end
    end
end
