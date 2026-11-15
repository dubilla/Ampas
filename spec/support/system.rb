RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [1280, 800] do |options|
      # Chrome's breached-password dialog (the specs sign in with "password")
      # silently swallows every click on the page behind it.
      options.add_preference('credentials_enable_service', false)
      options.add_preference('profile.password_manager_enabled', false)
      options.add_preference('profile.password_manager_leak_detection', false)
    end
  end
end
