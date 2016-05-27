class SessionsController < ApplicationController
  def new
  end

  def create_old
    user = User.find_by email: params[:session][:email].downcase
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to new_investor_path
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def create
    user = SingleSignOn.authenticate username: params[:session][:username],
                                     password: params[:session][:password]

    if user
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to new_investor_path
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  def destroy_sso
    # SingleSignOn.logout ?
  end
end
