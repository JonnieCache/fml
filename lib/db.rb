require File.join(__dir__, 'boot')

require 'sequel'

DB = Sequel.connect(DB_URL)

if ENV["RACK_ENV"] == 'development'
  require 'logger'
  logger = Logger.new(STDERR)
  logger.formatter = proc do |severity, datetime, progname, msg|
    next if msg =~ /^\(\d+\.\d+s\) (DESCRIBE|BEGIN|COMMIT|SET)/
    next if msg =~ /^\(\d+\.\d+s\) SELECT "pg_attribute"/
    
    color = if severity == "ERROR"
      [:red, :bold]
    elsif msg =~ /^\(\d+\.\d+s\) UPDATE/
      [:blue, :bright]
    elsif msg =~ /^\(\d+\.\d+s\) INSERT/
      [:green]
    else
      ['#FF7F50']
    end
    
    Paint[msg+"\n", *color]
  end

  DB.loggers << logger
end

require 'lib/sequel_init'
