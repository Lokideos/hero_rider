Sequel.migration do
  change do
    create_table(:game_acquisitions) do
      primary_key :id
      column :player_id, "integer"
      column :game_id, "integer"
      column :progress, "integer"
      column :last_updated_date, "timestamp without time zone"
      
      index [:last_updated_date]
    end
    
    create_table(:games) do
      primary_key :id
      column :trophy_service_id, "text"
      column :title, "text"
      column :platform, "text"
      column :icon_url, "text"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      column :trophy_service_source, "text", :default=>"trophy"
      
      index [:title]
      index [:title], :name=>:games_title_trgm_index
      index [:trophy_service_id]
    end
    
    create_table(:message_threads) do
      primary_key :id
      column :player_id, "integer"
      column :message_thread_id, "text", :null=>false
      column :last_modified_date, "text"
      column :last_message_index, "text"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      
      index [:message_thread_id]
      index [:message_thread_id], :name=>:message_threads_message_thread_id_key, :unique=>true
    end
    
    create_table(:players) do
      primary_key :id
      column :telegram_username, "text"
      column :trophy_account, "text"
      column :admin, "boolean"
      column :on_watch, "boolean"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      column :trophy_level, "integer", :default=>0
      column :level_up_progress, "integer", :default=>0
      column :trophy_ping, "boolean", :default=>false
      column :message_thread_name, "text"
      column :trophy_user_id, "text"
      
      index [:admin]
      index [:on_watch]
      index [:telegram_username]
      index [:trophy_account]
      index [:trophy_account], :name=>:players_trophy_account_key, :unique=>true
    end
    
    create_table(:schema_info) do
      column :version, "integer", :default=>0, :null=>false
    end
    
    create_table(:trophies) do
      primary_key :id
      column :game_id, "integer"
      column :trophy_service_id, "integer", :null=>false
      column :trophy_name, "text", :null=>false
      column :trophy_description, "text", :null=>false
      column :trophy_type, "text", :null=>false
      column :trophy_icon_url, "text", :null=>false
      column :trophy_small_icon_url, "text", :null=>false
      column :trophy_earned_rate, "text", :null=>false
      column :trophy_rare, "integer", :null=>false
      column :hidden, "boolean", :default=>false
      column :created_at, "timestamp without time zone", :default=>Sequel::CURRENT_TIMESTAMP
      column :updated_at, "timestamp without time zone", :null=>false
      
      index [:created_at]
      index [:hidden]
      index [:trophy_type]
      index [:updated_at]
    end
    
    create_table(:trophy_acquisitions) do
      primary_key :id
      column :player_id, "integer"
      column :trophy_id, "integer"
      column :earned_at, "timestamp without time zone"
      
      index [:player_id, :trophy_id], :name=>:trophy_acquisitions_player_id_trophy_id_key, :unique=>true
    end
    
    create_table(:trophy_hunters) do
      primary_key :id
      column :name, "text", :null=>false
      column :email, "text", :null=>false
      column :password, "text", :null=>false
      column :app_context, "text", :default=>"inapp_ios", :null=>false
      column :client_id, "text", :null=>false
      column :client_secret, "text", :null=>false
      column :duid, "text", :null=>false
      column :state, "text", :null=>false
      column :scope, "text", :null=>false
      column :active, "boolean", :default=>false
      column :refresh_token, "text"
      column :refresh_token_expiration, "timestamp without time zone"
      column :created_at, "timestamp without time zone", :null=>false
      column :updated_at, "timestamp without time zone", :null=>false
      
      index [:client_id], :name=>:trophy_hunters_client_id_key, :unique=>true
      index [:client_secret], :name=>:trophy_hunters_client_secret_key, :unique=>true
      index [:email], :name=>:trophy_hunters_email_key, :unique=>true
      index [:name]
      index [:name], :name=>:trophy_hunters_name_key, :unique=>true
    end
  end
end
