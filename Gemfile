source 'https://rubygems.org'

ruby '2.7.8'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '7.1.5.1'
# Use sqlite3 as the database for Active Record
gem 'pg'
# Pinned to the highest release supporting Ruby 2.7. Closing the outstanding
# ReDoS advisory needs >= 1.19.3, which requires Ruby >= 3.2 -- Phase 4.
gem 'nokogiri', '~> 1.15.7'
# Use SCSS for stylesheets
gem 'sassc-rails', '~> 2.1'
# Terser replaces Uglifier, which is ES5-only and cannot parse the `const` in
# Rails 7's bundled Active Storage JavaScript.
gem 'terser', '~> 1.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Pinned: 4.2.0 is a syntax error on Ruby 2.6 (brace block after an
# unparenthesized hash arg in sessions_controller.rb). Fixed upstream in 4.4.0.
# Transitive dependency of sass-listen -> rb-inotify, which only resolves on
# Linux (macOS uses rb-fsevent). ffi 1.17 dropped Ruby 2.6, and Bundler 1.17
# locks it anyway without checking required_ruby_version, so CI fails where
# local development cannot. Drop this pin once Phase 4 lands Ruby 3.3.
gem 'ffi', '< 1.17'

gem 'devise', '~> 4.9.4'


gem 'pundit'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'rspec-rails', '~> 6.1'
  gem 'factory_bot_rails', '~> 5.2'
  gem 'capybara', '~> 3.36'
  gem 'timecop', '~> 0.9'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 4.2'

  gem 'pry'
  gem 'pry-byebug'

  gem 'rubocop', require: false

  end
