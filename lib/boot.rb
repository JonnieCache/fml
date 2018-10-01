$VERBOSE = nil
ROOT_DIR = File.join(__dir__, '..')
$:.unshift(ROOT_DIR)

require 'rubygems'
require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'])

require 'dotenv'
Dotenv.load *%W{
  .env.#{ENV["RACK_ENV"]}
  .env
}

require 'lib/core_ext/date'
require 'lib/core_ext/object'

db_url = 'postgres://'
db_url << "#{ENV['DB_USERNAME']}:#{ENV['DB_PASSWORD']}@" if ENV['DB_USERNAME'].present? #&& ENV['DB_PASSWORD'].present?
db_url << ENV['DB_HOST'] if ENV['DB_HOST'].present?
db_url << "/#{ENV['DB_NAME']}"
DB_URL = db_url

DB_CONFIG = {
  adapter: 'postgres',
  user: ENV['DB_USERNAME'],
  password: ENV['DB_PASSWORD'],
  host: ENV['DB_HOST'],
  database: ENV['DB_NAME'],
}
