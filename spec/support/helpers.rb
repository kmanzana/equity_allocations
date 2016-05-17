module Helpers
  def is_logged_in?
    !session[:user_id].nil?
  end

  def log_in_as(user, options = {})
    password    = options[:password]    || 'password'
    remember_me = options[:remember_me] || '1'

    if integration_test?
      post login_path, session: { username:    user.username,
                                  password:    password,
                                  remember_me: remember_me }
    else
      session[:user_id] = user.id
    end
  end

  private

  def integration_test?
    defined? post_via_redirect
  end
end
