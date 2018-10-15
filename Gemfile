# frozen_string_literal: true
source "https://rubygems.org"

gem 'roda'
gem 'rodauth', '1.18.0'
gem 'haml'
gem 'puma'
gem 'rake'
gem 'dotenv'
gem 'sequel', '5.2.0'
gem 'sequel_pg', require: false
gem 'pg'
gem 'state_machines'
gem 'state_machines-activemodel'
gem 'pry'
gem 'racksh'
gem 'awesome_print'
gem 'rasem'
gem 'color-generator'
gem 'paint'
gem 'jwt'
gem 'bcrypt'
gem 'mail'
# gem 'rubyzip', '>1.2.1'

group :development do
  gem 'guard'
  gem 'rb-fsevent', "<0.10"
  gem 'yard'
end

group :test do
  gem 'guard-rspec'
  gem 'fuubar'
  gem 'rspec-nc'
  gem 'terminal-notifier', '1.7.1'
  gem 'database_cleaner'
  gem 'rspec'
  gem 'factory_bot'
  gem 'faker'
  gem 'rack-test'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'capybara-screenshot'
end

group :development, :test do
  gem 'pry-byebug', git: 'https://github.com/deivid-rodriguez/pry-byebug'
  gem 'byebug', git: 'https://github.com/deivid-rodriguez/byebug'
  gem 'pry-doc'
  gem 'guard-rack'
end
