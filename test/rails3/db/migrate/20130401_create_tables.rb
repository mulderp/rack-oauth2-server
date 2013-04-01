class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :clients do |t|
      t.string :secret
      t.string :scope
      t.string :redirect_uri
      t.string :display_name
      t.string :link
      t.string :image_url
      t.string :notes
    end
  end
    def self.down
#    drop_table :users
#    drop_table :admins
  end
end
