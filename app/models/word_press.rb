class WordPress
  include HTTParty

  base_uri 'https://equityallocations.com'
  format :json

  def WordPress.authenticate username:, password:
    # raise readable error if no WORD_PRESS_CLIENT_ID or WORD_PRESS_CLIENT_SECRET

    response = post '/oauth/token', body: {
      username: username,
      password: password,
      client_id: ENV['WORD_PRESS_CLIENT_ID'],
      client_secret: ENV['WORD_PRESS_CLIENT_SECRET'],
      grant_type: :password
    }

    body = response.parsed_response

    case
    when response.code == 200
      new access_token: body['access_token'], refresh_token: body['refresh_token']
    when response.code >= 400
      new error: body['error_description']
    else
      message = "unused WordPress response code: #{repsonse.code}"
      Rails.logger.warn message
      new error: message
    end
  end

  def current_user
    response = WordPress.get '/wp-json/wp/v2/users/me', query: {
      _envelope: nil,
      context: :edit,
      access_token: access_token
    }

    body = response.parsed_response['body']

    if response.code == 401 && body['error'] == 'expired_token'
      # refresh
      # current_user
    else
      body
    end
  end

  def destroy
    response = WordPress.get '/oauth/destroy', query: {
      access_token: access_token,
      refresh_token: refresh_token
    }

    response.parsed_response
  end

  def error?
    !error.nil?
  end

  private

  attr_reader :access_token, :refresh_token, :error

  def initialize access_token: nil, refresh_token: nil, error: nil
    @access_token = access_token
    @refresh_token = refresh_token
    @error = error
  end

  # example access token expiration response
  # {
  #   "body": {
  #     "code": "rest_not_logged_in",
  #     "message": "You are not currently logged in.",
  #     "data": {
  #       "status": 401
  #     }
  #   },
  #   "status": 401,
  #   "headers": {
  #     "Allow": "GET"
  #   }
  # }

  # def refresh
  #   response = post '/oauth/token', body: {
  #     refresh_token: refresh_token,
  #     client_id: ENV['WORD_PRESS_CLIENT_ID'],
  #     client_secret: ENV['WORD_PRESS_CLIENT_SECRET'],
  #     grant_type: :refresh_token
  #   }
  # end
end
