class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
    end
  end
    def self.down
    drop_table :users
    drop_table :admins
  end
end
