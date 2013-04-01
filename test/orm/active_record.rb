ActiveRecord::Migration.verbose = true
# ActiveRecord::Base.logger = Logger.new(nil)

ActiveRecord::Migrator.migrate(File.expand_path("../../rails3/db/migrate/", __FILE__))

class ActiveSupport::TestCase
#  self.use_transactional_fixtures = true
#  self.use_instantiated_fixtures  = false
end
