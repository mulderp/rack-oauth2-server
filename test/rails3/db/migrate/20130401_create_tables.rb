class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :clients do |t|
      t.string :secret, :null => false, :default => ""
      t.string :scope, :null => false, :default => ""
      t.string :redirect_uri, :null => false, :default => ""
      t.string :display_name, :null => false, :default => ""
      t.string :link, :null => false, :default => ""
      t.string :image_url, :null => false, :default => ""
      t.string :notes, :null => false, :default => ""
    end

    create_table :access_grants do |t|
      t.string :identity
      t.string :scope
      t.string :client_id
      t.string :redirect_uri
      t.string :created_at
      t.string :expires_at
      t.string :granted_at
      t.string :access_token
      t.string :revoked
    end
  end
    def self.down
#    drop_table :users
#    drop_table :admins
  end
end
