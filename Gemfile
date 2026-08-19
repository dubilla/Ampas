source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.8.1'
# Use sqlite3 as the database for Active Record
gem 'pg'
# Pinned: 1.8.2 vendors libxml2 2.9 and no longer compiles on modern toolchains.
# 1.13.x is the highest release supporting Ruby 2.6. See docs/rails-upgrade-plan.md.
gem 'nokogiri', '~> 1.13.10'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
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
gem 'devise', '~> 4.7.3'


gem 'pundit'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'rspec-rails'
  gem 'factory_bot_rails', '~> 5.2'
  gem 'capybara', '~> 3.36'
  gem 'timecop', '~> 0.9'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.7'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'pry'
  gem 'pry-byebug'

  gem 'rubocop', require: false

  end
