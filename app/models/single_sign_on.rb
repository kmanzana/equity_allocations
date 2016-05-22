class SingleSignOn
  def SingleSignOn.authenticate credentials
    single_sign_on = new credentials
    single_sign_on.send :find_or_create_user
  end

  # requires storing of access_token and refresh_token, which isn't necessary for anything else?
  # def SingleSignOn.logout user
  #   client.destroy
  # end

  private

  attr_reader :credentials

  def initialize credentials
    @credentials = credentials
  end

  def find_or_create_user
    return false if client.error?

    User.find_by(word_press_id: provider_user['id']) || create_user
  end

  def client
    @client ||= WordPress.authenticate credentials
  end

  def create_user
    User.create!(user_params).tap do |user|
      investor = user.build_investor investor_params
      investor.save validate: false
    end
  end

  def user_params
    {
      word_press_id: provider_user['id'],
      username: credentials[:username]
    }
  end

  def investor_params
    {
      person: true, # to be removed once orgs are supported
      first_name: provider_user['first_name'],
      last_name: provider_user['last_name'],
      email: provider_user['email']
    }
  end

  def provider_user
    @provider_user = client.current_user
  end
end
