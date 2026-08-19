require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'signing in' do
    it 'accepts valid credentials' do
      user = create(:user, password: 'password')
      sign_in_as(user)

      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(response.body).to include('>Logout</a>')
    end

    it 'rejects invalid credentials' do
      user = create(:user, password: 'password')
      sign_in_as(user, password: 'wrong')

      expect(response.body).not_to include('>Logout</a>')
    end
  end

  it 'signs out' do
    sign_in_as(create(:user))
    sign_out!
    follow_redirect!

    expect(response.body).to include('>Log in</a>')
  end

  it 'registers a new user' do
    expect {
      post '/users', user: { email: 'brand-new@example.com', password: 'password', password_confirmation: 'password' }
    }.to change(User, :count).by(1)
  end

  describe 'post-sign-in redirect' do
    let(:user) { create(:user) }

    it 'returns to the referring page' do
      post '/users/sign_in',
           { user: { email: user.email, password: 'password' } },
           { 'HTTP_REFERER' => 'http://www.example.com/award_ceremonies' }

      expect(response).to redirect_to('http://www.example.com/award_ceremonies')
    end

    # Guards against bouncing the user straight back to the login form.
    it 'does not return to the sign-in page itself' do
      post '/users/sign_in',
           { user: { email: user.email, password: 'password' } },
           { 'HTTP_REFERER' => 'http://www.example.com/users/sign_in' }

      expect(response).to redirect_to('http://www.example.com/')
    end
  end

  describe 'layouts' do
    it 'uses the devise layout for devise controllers and the app layout elsewhere' do
      # The devise layout omits the auth nav link that the application layout renders.
      get '/users/sign_in'
      expect(response.body).not_to include('>Log in</a>')

      get '/'
      expect(response.body).to include('>Log in</a>')
    end
  end
end
