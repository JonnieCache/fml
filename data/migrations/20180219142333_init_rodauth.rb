require 'rodauth/migrations'

Sequel.migration do
  up do
    superuser_query = "SELECT rolsuper FROM pg_roles WHERE rolname = current_user"
    superuser = DB[superuser_query].get
    
    if superuser
      run "CREATE EXTENSION IF NOT EXISTS citext"
    elsif !DB[:pg_extension].where(extname: 'citext').any?
      puts "FML requires the 'citext' postgres extension."
      puts "Unfortunately superuser permissions are required to install it."
      puts "Connect to the DB as a superuser and run `CREATE EXTENSION citext;`"
      puts "Then run the migrations again."
      exit
    end
    
    extension :date_arithmetic
    
    # Used by the account verification and close account features
    create_table(:account_statuses) do
      Integer :id, :primary_key=>true
      String :name, :null=>false, :unique=>true
    end
    from(:account_statuses).import([:id, :name], [[1, 'Unverified'], [2, 'Verified'], [3, 'Closed']])

    alter_table(:users) do
      add_foreign_key :status_id, :account_statuses, :null=>false, :default=>1
      rename_column :password, :password_hash
      set_column_type :email, :citext
      set_column_not_null :email
      add_constraint :valid_email, :email=>/^[^,;@ \r\n]+@[^,@; \r\n]+\.[^,@; \r\n]+$/
      add_index :email, :unique=>true, :where=>{:status_id=>[1, 2]}
    end

    deadline_opts = proc do |days|
      {:null=>false, :default=>Sequel.date_add(Sequel::CURRENT_TIMESTAMP, :days=>days)}
    end

    # Used by the password reset feature
    create_table(:account_password_reset_keys) do
      foreign_key :id, :users, :primary_key=>true, :type=>:Bignum
      String :key, :null=>false
      DateTime :deadline, deadline_opts[1]
    end

    # Used by the remember me feature
    create_table(:account_remember_keys) do
      foreign_key :id, :users, :primary_key=>true, :type=>:Bignum
      String :key, :null=>false
      DateTime :deadline, deadline_opts[14]
    end

    # create_table(:account_password_hashes) do
    #   foreign_key :id, :users, :primary_key=>true, :type=>:Bignum
    #   String :password_hash, :null=>false
    # end
    # Rodauth.create_database_authentication_functions(self)
    
    # user = get(Sequel.lit('current_user')).sub(/_password\z/, '')
    # # run "REVOKE ALL ON account_password_hashes FROM public"
    # run "REVOKE ALL ON FUNCTION rodauth_get_salt(int8) FROM public"
    # run "REVOKE ALL ON FUNCTION rodauth_valid_password_hash(int8, text) FROM public"
    # run "GRANT INSERT, UPDATE, DELETE ON account_password_hashes TO #{user}"
    # run "GRANT SELECT(id) ON account_password_hashes TO #{user}"
    # run "GRANT EXECUTE ON FUNCTION rodauth_get_salt(int8) TO #{user}"
    # run "GRANT EXECUTE ON FUNCTION rodauth_valid_password_hash(int8, text) TO #{user}"
  end

  down do
    drop_table(
               :account_recovery_codes,
               :account_session_keys,
               :account_activity_times,
               :account_password_change_times,
               :account_lockouts,
               :account_login_failures,
               :account_remember_keys,
               :account_login_change_keys,
               :account_verification_keys,
               :account_password_reset_keys,
               :account_statuses)
    
    Rodauth.drop_database_previous_password_check_functions(self)
    Rodauth.drop_database_authentication_functions(self)
    drop_table(:account_previous_password_hashes, :account_password_hashes)
  end
end
