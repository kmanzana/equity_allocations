source 'https://rubygems.org'

ruby '2.3.1'

gem 'rails', '4.2.6'
gem 'bcrypt'
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'

gem 'jquery-rails'
gem 'turbolinks'

gem 'crowd_pay'
gem 'httparty'
gem 'draper'

group :production do
  gem 'rails_12factor'
  gem 'puma'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'guard-rspec', require: false
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem 'spring'
end

group :test do
  gem 'factory_girl_rails'
end
