class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      reset_session
      remember user
      log_in user
      flash[:success] = "ログインしました"
      redirect_to user
    else
      flash.now[:danger] = "Invalid email/password combination"
      render "new", status: :unprocessable_content
    end
  end

  def destroy
    log_out
    redirect_to root_path, status: :see_other
  end
end
