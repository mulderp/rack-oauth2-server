ENV["RAILS_ENV"] = "test"
ENV["RACK_ENV"] = "test"

require 'test/unit'
require 'mocha/setup'
require 'logger'
require 'shoulda'

$: << File.dirname(__FILE__) + "/../lib"
$: << File.dirname(__FILE__)
$: << File.expand_path(File.dirname(__FILE__) + "/..")
require "rack/oauth2/server"
require "rack/oauth2/server/admin"


ENV["DB"] = "rack_oauth2_server_test"
# DATABASE = Mongo::Connection.new[ENV["DB"]]
FRAMEWORK = ENV["FRAMEWORK"] || "rails"


$logger = Logger.new("test.log")
$logger.level = Logger::DEBUG
Rack::OAuth2::Server::Admin.configure do |config|
  config.set :logger, $logger
  config.set :logging, true
  config.set :raise_errors, true
  config.set :dump_errors, true
  config.oauth.expires_in = 86400 # a day
  config.oauth.logger = $logger
end


case FRAMEWORK
when "sinatra", nil

  require "sinatra/base"
  puts "Testing with Sinatra #{Sinatra::VERSION}"
  require File.dirname(__FILE__) + "/sinatra/my_app"
  
  class Test::Unit::TestCase
    def app
      Rack::Builder.new do
        map("/oauth/admin") { run Server::Admin }
        map("/") { run MyApp }
      end
    end

    def config
      MyApp.oauth
    end
  end

when "rails"

  puts "*** Testing with Rails"
  RAILS_ENV = "test"
  RAILS_ROOT = File.dirname(__FILE__) + "/rails3"
  ORM = :active_record

  require "rails"
  require "rails/test_help"

  if defined?(Rails::Railtie)
    puts "Testing with Rails #{Rails.version}"
    # Rails 3.x
    require "rack/oauth2/server/railtie"
    require "#{RAILS_ROOT}/config/environment"
#    require 'active_support/test_case'
#    require 'active_record/fixtures'
    require "orm/#{ORM}"
  
    class Test::Unit::TestCase
      def app
        ::Rails.application
      end

      def config
        ::Rails.configuration.oauth
      end
    end

  else
    # Rails 2.x
    RAILS_ROOT = File.dirname(__FILE__) + "/rails2"
    require "initializer"
    require "action_controller"
    require File.dirname(__FILE__) + "/rails2/config/environment"
    puts "Testing with Rails #{Rails.version}"
  
    class Test::Unit::TestCase
      def app
        ActionController::Dispatcher.new
      end

      def config
        ::Rails.configuration.oauth
      end
    end
  end

else
  puts "Unknown framework #{FRAMEWORK}"
  exit -1
end


class Test::Unit::TestCase
  include Rack::Test::Methods
  include Rack::OAuth2

  def setup
    Server::Admin.scope = %{read write}
    @client = Server.register(:display_name=>"UberClient", :redirect_uri=>"http://uberclient.dot/callback", :scope=>%w{read write oauth-admin})
  end

  attr_reader :client, :end_user

  def teardown
  end

  def mongo_teardown
    Server::Client.collection.drop
    Server::AuthRequest.collection.drop
    Server::AccessGrant.collection.drop
    Server::AccessToken.collection.drop
    Server::Issuer.collection.drop
  end
end
