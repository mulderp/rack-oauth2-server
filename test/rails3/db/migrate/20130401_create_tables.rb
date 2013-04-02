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
  end
    def self.down
#    drop_table :users
#    drop_table :admins
  end
end
