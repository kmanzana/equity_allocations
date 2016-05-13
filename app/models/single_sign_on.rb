class SingleSignOn
  def SingleSignOn.authenticate credentials
    single_sign_on = new credentials
    single_sign_on.send :find_or_create_user
  end

  # requires storing of access_token and refresh_token, which isn't necessary for anything else?
#   def SingleSignOn.logout user
#     client.destroy
#   end

  private

  attr_reader :credentials

  def initialize credentials
    @credentials = credentials
  end

  def find_or_create_user
    return false if client.error?

    User.create_with(user_params).find_or_create_by! word_press_id: user['id']
  end

  def client
    @client ||= WordPress.authenticate credentials
  end

  def user_params
    {
      first_name: user['first_name'],
      last_name: user['last_name'],
      email: user['email'],
      username: credentials[:username],
      password: credentials[:password],
      password_confirmation: credentials[:password]
    }
  end

  def user
    @user = client.current_user
  end
end
