class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      UserMailer.account_activation(@user).deliver_now
      flash[:info] = "アカウントを有効にするにはメールを確認してください"
      redirect_to root_url
    else
      render "new", status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:success] = "プロフィールを編集しました"
      redirect_to @user
    else
      render "edit", status: :unprocessable_content
    end
  end

  def destroy
    user = User.find(params[:id])
    if user&.destroy
      flash[:success] = "#{user.name}を削除しました"
    else
      flash[:danger] = "ユーザーの削除に失敗しました"
    end
    redirect_to users_url, status: :see_other
  end

  private #-----------------------------------------------------------------

    def user_params
      params.require(:user).permit(:name,
                                   :email,
                                   :password,
                                   :password_confirmation
                                  )
    end

    #beforeフィルタ---------------------------------------------

    #ログイン済みユーザーかどうか確認
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください"
        redirect_to login_path, status: :see_other
      end
    end

    #正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      unless current_user?(@user)
        flash[:danger] = "アクセス権がありません"
        redirect_to(root_url, status: :see_other)
      end
    end

    def admin_user
      redirect_to(root_url, status: :see_other) unless current_user.admin?
    end
end
