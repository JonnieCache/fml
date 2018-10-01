task :boot do
  require File.join(__dir__, '..', '..', 'lib', 'boot')
end

task :db => :boot do
  require File.join(__dir__, '..', '..', 'lib', 'db')
end

namespace :gen do
  
  desc "generate a new migration"
  task :migration  => :boot do |t,args|
    name = ARGV.pop
    task name.to_sym do ; end
    
    if name.blank?
      error "Specify a name. rake gen:migration migration_name"
    else
      ts = Time.now.strftime('%Y%m%d%H%M%S')
      
      file = "#{ROOT_DIR}/data/migrations/#{ts}_#{name}.rb"
      say "Create #{file}"
      File.open(file, 'w') do |f|
        f.write("Sequel.migration do\n")
        f.write("  change do\n")
        f.write("    \n");
        f.write("  end\n")
        f.write("end\n")
      end

      `$EDITOR #{file}:3:5`
    end
  end

end

namespace :db do
  
  desc 'create database'
  task :create => :boot do
    if !DB_URL.nil?
      Sequel.connect(DB_CONFIG.merge('database' => 'postgres')) do |db|
        db.loggers << Logger.new(STDERR)
        db.execute "DROP DATABASE IF EXISTS #{DB_CONFIG[:database]}"
        db.execute "CREATE DATABASE #{DB_CONFIG[:database]}"
      end
    else
      error "db settings not present in environment"
    end
  end

  desc "run database migrations"
  task :migrate => :boot do
    if !DB_URL.nil?
      puts `sequel -E -r ./lib/sequel_init -m data/migrations #{DB_URL}`
    else
      error "db settings not present in environment"
    end
  end

  desc "roll back database"
  task :rollback => :db do
    files = Dir["data/migrations/*.rb"]
    if !DB_URL.nil?
      if (last = DB[:schema_migrations].order(:filename).last[:filename] rescue nil) && ts = (last.gsub(/_.*/,'').to_i - 1) rescue nil
        puts `sequel -E -r ./lib/sequel_init -m data/migrations -M #{ts} #{DB_URL}`
      else
        puts `sequel -E -r ./lib/sequel_init -m data/migrations -M 0 #{DB_URL}`
      end
    else
      error "DB_URL not present in environment"
    end
  end
  
  namespace :test do
    desc 'clone dev db to test db'
    task :clone => :boot do
      `echo "DROP DATABASE IF EXISTS fml_test; CREATE DATABASE fml_test WITH TEMPLATE fml_development" | psql postgres`
    end
  end

  namespace :schema do
    desc "dump database schema into data/schema.rb"
    task :dump => :boot do
      if !DB_URL.nil?
        say "Dumping db schema into data/schema.rb"
        `sequel -d #{DB_URL} > data/schema.rb`
      else
        error "DB_URL not present in environment"
      end
    end

  end
end

def error msg
  puts "#{`tput setaf 1`}#{msg}#{`tput sgr0`}"
end

def say msg
  puts "#{`tput setaf 2`}#{msg}#{`tput sgr0`}"
end
