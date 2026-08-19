# Signs in through the real Devise endpoint rather than through
# Devise::Test::ControllerHelpers. Going over HTTP keeps these specs
# independent of Devise's internal test API, which has changed across
# versions -- important for a suite meant to survive a framework upgrade.
module AuthHelpers
  def sign_in_as(user, password: 'password')
    post '/users/sign_in', params: { user: { email: user.email, password: password } }
  end

  def sign_out!
    delete '/users/sign_out'
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
