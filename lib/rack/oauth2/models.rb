require "openssl"
require "rack/oauth2/server/errors"
require "rack/oauth2/server/utils"


module Rack
  module OAuth2
    class Server

      class << self

        # Long, random and hexy.
        def secure_random
          OpenSSL::Random.random_bytes(32).unpack("H*")[0]
        end
        
        # @private
        def create_indexes(&block)
          if block
            @create_indexes ||= []
            @create_indexes << block
          elsif @create_indexes
            @create_indexes.each do |block|
              block.call
            end
            @create_indexes = nil
          end
        end
 
        def database
          @database ||= ActiveRecord::Base.connection #Server.options.database
          raise "No database Configured. You must configure it using Server.options.database = Mongo::Connection.new()[db_name]" unless @database
          raise "You set Server.database to #{Server.database.class}, should be a Mongo::DB object" unless Mongo::DB === @database
          @database
        end
      end
 
    end
  end
end


require "rack/oauth2/models/active_record/client"
require "rack/oauth2/models/active_record/auth_request"
require "rack/oauth2/models/active_record/access_grant"
require "rack/oauth2/models/active_record/access_token"
require "rack/oauth2/models/active_record/issuer"
