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

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).not_to include('>Logout</a>')
    end
  end

  it 'signs out' do
    sign_in_as(create(:user))
    sign_out!
    expect(response).to have_http_status(:see_other)
    follow_redirect!

    expect(response.body).to include('>Log in</a>')
  end

  it 'registers a new user' do
    expect {
      post '/users', params: { user: { email: 'brand-new@example.com', password: 'password', password_confirmation: 'password' } }
    }.to change(User, :count).by(1)
  end

  describe 'post-sign-in redirect' do
    let(:user) { create(:user) }

    # A browser's sign-in POST carries the sign-in page (query string included) as
    # its referer, so returning to the referer would bounce straight back to it.
    ['http://www.example.com/users/sign_in', 'http://www.example.com/users/sign_in?redirect_to=%40evil.com',
     'http://www.example.com/award_ceremonies'].each do |referer|
      it "goes to the root rather than the referer #{referer}" do
        post '/users/sign_in',
             params: { user: { email: user.email, password: 'password' } },
             headers: { 'HTTP_REFERER' => referer }

        expect(response).to redirect_to('http://www.example.com/')
        follow_redirect!(headers: { 'HTTP_REFERER' => referer })
        expect(response).to have_http_status(:ok)
      end
    end

    it 'returns to a local redirect_to path' do
      get '/users/sign_in', params: { redirect_to: '/pools' }
      post '/users/sign_in',
           params: { user: { email: user.email, password: 'password' } },
           headers: { 'HTTP_REFERER' => 'http://www.example.com/users/sign_in?redirect_to=%2Fpools' }

      expect(response).to redirect_to('http://www.example.com/pools')
    end

    it 'ignores a redirect_to too long to fit in the session cookie' do
      get '/users/sign_in', params: { redirect_to: "/#{'a' * 5000}" }
      expect(response).to have_http_status(:ok)

      sign_in_as(user)
      expect(response).to redirect_to('http://www.example.com/')
    end

    ['@evil.com', '.evil.com', 'pools/1', '//evil.com', '/\\evil.com', 'https://evil.com/pools'].each do |target|
      it "ignores a non-local redirect_to of #{target.inspect} and can still sign in" do
        get '/users/sign_in', params: { redirect_to: target }
        sign_in_as(user)
        expect(response).to redirect_to('http://www.example.com/')

        sign_out!
        get '/users/sign_in'
        sign_in_as(user)
        expect(response).to redirect_to('http://www.example.com/')
      end
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
