class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :clients do |t|
      t.string :secret, :null => false, :default => ""
      t.string :scope, :null => false, :default => ""
      t.string :redirect_uri, :null => false, :default => ""
      t.string :display_name, :null => false, :default => ""
      t.string :link
      t.string :image_url
      t.string :notes
      t.integer :tokens_granted, :default => 0
      t.integer :tokens_revoked, :default => 0
      t.boolean :revoked
      t.timestamps
    end

    create_table :access_grants do |t|
      t.string :identity
      t.string :scope
      t.integer :client_id
      t.string :redirect_uri
      t.integer :created_at
      t.integer :expires_at
      t.integer :granted_at
      t.string :access_token
      t.string :revoked
    end

    create_table :access_tokens do |t|
      t.string :identity
      t.string :scope
      t.string :token
      t.integer :client_id
      t.string :redirect_uri
      t.integer :created_at
      t.integer :expires_at
      t.integer :granted_at
      t.string :access_token
      t.string :revoked
    end
  end
    def self.down
#    drop_table :users
#    drop_table :admins
  end
end
