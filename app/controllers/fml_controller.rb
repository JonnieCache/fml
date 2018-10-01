require 'app/models/user'

class FMLController < Roda
  use Rack::Session::Cookie
  
  plugin :slash_path_empty
  plugin :default_headers, 
    'Content-Type' => 'application/json'    
  plugin :render,
    engine: 'haml',
    views: ROOT_DIR+'/app/views'
  plugin :all_verbs
  plugin :hooks
  plugin :halt
  plugin :rodauth, json: :only, csrf: false do
    db DB
    enable *[
      :login,
      :logout,
      :create_account,
      :change_login,
      :change_password,
      :remember,
      :reset_password,
      :jwt
    ]
    accounts_table :users
    account_password_hash_column :password_hash
    json_response_custom_error_status? true
    create_account_route 'signup'
    require_login_confirmation? false
    # create_account_error_flash 'lmao'
    
    jwt_secret ENV.delete('SESSION_SECRET') || SecureRandom.random_bytes(30)
  end
  
  before do
    rodauth.load_memory
    request.rodauth
  end
  
  def jparams
    @jparams ||= JSON.parse request.body.read
  end

end

