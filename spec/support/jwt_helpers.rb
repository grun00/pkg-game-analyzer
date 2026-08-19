module JwtHelpers
  # Logs in via the API and returns the Authorization header string containing
  # the freshly-issued JWT (e.g. "Bearer eyJ...").
  def jwt_token_for(user)
    post user_session_path, params: {
      user: { email: user.email, password: user.password }
    }, as: :json
    response.headers["Authorization"]
  end

  # Convenience: returns a headers hash ready to pass to request helpers.
  def auth_headers(user)
    { "Authorization" => jwt_token_for(user) }
  end
end

RSpec.configure do |config|
  config.include JwtHelpers, type: :request
end
