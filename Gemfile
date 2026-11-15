source 'https://rubygems.org'

ruby '3.3.13'

rails_version = '7.1.6'
gem 'actionmailer', rails_version
gem 'actionpack', rails_version
gem 'actionview', rails_version
gem 'activejob', rails_version
gem 'activemodel', rails_version
gem 'activerecord', rails_version
gem 'activesupport', rails_version
gem 'railties', rails_version
gem 'sprockets-rails', '~> 3.5'

gem 'pg'
# 1.19.3 fixes GHSA-c4rq-3m3g-8wgx.
gem 'nokogiri', '>= 1.19.3'
gem 'puma', '~> 8.0'

# Use SCSS for stylesheets
gem 'sassc-rails', '~> 2.1'
# Uglifier can't parse ES6.
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

gem 'devise', '~> 4.9.4'


gem 'pundit'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'rspec-rails', '~> 6.1'
  gem 'factory_bot_rails', '~> 6.4'
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
