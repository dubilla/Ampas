source 'https://rubygems.org'

ruby '3.4.13'

rails_version = '8.1.4.1'
gem 'actionmailer', rails_version
gem 'actionpack', rails_version
gem 'actionview', rails_version
gem 'activejob', rails_version
gem 'activemodel', rails_version
gem 'activerecord', rails_version
gem 'activesupport', rails_version
gem 'propshaft', '~> 1.3'
gem 'railties', rails_version

gem 'pg'
# 1.19.3 fixes GHSA-c4rq-3m3g-8wgx.
gem 'nokogiri', '>= 1.19.3'
gem 'puma', '~> 8.0'

gem 'importmap-rails', '~> 2.2'
gem 'turbo-rails', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'devise', '~> 5.0.4'

gem 'pundit'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'capybara', '~> 3.40'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'rspec-rails', '~> 8.1.0'
  gem 'selenium-webdriver', '~> 4.52'
  gem 'timecop', '~> 0.9'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 4.2'

  gem 'pry'
  gem 'pry-byebug'

  gem 'rubocop', require: false
end
