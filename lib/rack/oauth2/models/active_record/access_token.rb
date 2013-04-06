module Rack
  module OAuth2
    class Server

      # Access token. This is what clients use to access resources.
      #
      # An access token is a unique code, associated with a client, an identity
      # and scope. It may be revoked, or expire after a certain period.
      class AccessToken < ActiveRecord::Base
        class << self

          # Find AccessToken from token. Does not return revoked tokens.
          def from_token(token)
            # Server.new_instance self, collection.find_one({ :_id=>token, :revoked=>nil })
            puts "tttt ooo ken"
            AccessToken.where(:token => token, :revoked => nil).first
          end

          # Get an access token (create new one if necessary).
          #
          # You can set optional expiration in seconds. If zero or nil, token
          # never expires.
          def get_token_for(identity, client, scope, expires = nil)
            raise ArgumentError, "Identity must be String or Integer" unless String === identity || Integer === identity
            scope = Utils.normalize_scope(scope) & YAML.load(client.scope) # Only allowed scope
            puts scope.inspect
            token = where("(expires_at is null or expires_at >= ?) and identity = ? and client_id = ? and revoked is null", Time.now.to_i, identity, client.id)
            unless token.present?
              return create_token_for(client, scope, identity, expires)
            end
            token.first
          end

          # Creates a new AccessToken for the given client and scope.
          def create_token_for(client, scope, identity = nil, expires = nil)
            expires_at = Time.now.to_i + expires if expires && expires != 0
            token = { :token =>Server.secure_random, :scope=>scope,
                      :client_id=>client.id, :created_at=>Time.now.to_i,
                      :expires_at=>expires_at, :revoked=>nil }
            token[:identity] = identity if identity
            access_token = AccessToken.create token
            client.tokens_granted += 1
            client.save
            access_token
          end

          # Find all AccessTokens for an identity.
          def from_identity(identity)
            self.where({ :identity=>identity })
          end

          # Returns all access tokens for a given client, Use limit and offset
          # to return a subset of tokens, sorted by creation date.
          def for_client(client_id, offset = 0, limit = 100)
            client_id = 1 #BSON::ObjectId(client_id.to_s)
            self.where(:client_id=>client_id ).order("created_at ASC").limit(100)
          end

          # Returns count of access tokens.
          #
          # @param [Hash] filter Count only a subset of access tokens
          # @option filter [Integer] days Only count that many days (since now)
          # @option filter [Boolean] revoked Only count revoked (true) or non-revoked (false) tokens; count all tokens if nil
          # @option filter [String, ObjectId] client_id Only tokens grant to this client
          def count(filter = {})
            select = {}
            if filter[:days]
              now = Time.now.to_i
              range = { :$gt=>now - filter[:days] * 86400, :$lte=>now }
              select[ filter[:revoked] ? :revoked : :created_at ] = range
            elsif filter.has_key?(:revoked)
              select[:revoked] = filter[:revoked] ? { :$ne=>nil } : { :$eq=>nil }
            end
            select[:client_id] = BSON::ObjectId(filter[:client_id].to_s) if filter[:client_id]
            self.find(select).count
          end

          def historical(filter = {})
            days = filter[:days] || 60
            select = { :$gt=> { :created_at=>Time.now - 86400 * days } }
            select = {}
            if filter[:client_id]
              select[:client_id] = BSON::ObjectId(filter[:client_id].to_s)
            end
            raw = Server::AccessToken.group("function (token) { return { ts: Math.floor(token.created_at / 86400) } }",
              select, { :granted=>0 }, "function (token, state) { state.granted++ }")
            raw.sort { |a, b| a["ts"] - b["ts"] }
          end

        end

        # Access token. As unique as they come.
#        attr_reader :_id
        # alias :token :id
        # The identity we authorized access to.
#        attr_reader :identity
#        # Client that was granted this access token.
#        attr_reader :client_id
#        # The scope granted to this token.
#        attr_reader :scope
#        # When token was granted.
#        attr_reader :created_at
#        # When token expires for good.
#        attr_reader :expires_at
#        # Timestamp if revoked.
#        attr_accessor :revoked
#        # Timestamp of last access using this token, rounded up to hour.
#        attr_accessor :last_access
#        # Timestamp of previous access using this token, rounded up to hour.
#        attr_accessor :prev_access

        # Updates the last access timestamp.
        def access!
          today = (Time.now.to_i / 3600) * 3600
          if last_access.nil? || last_access < today
            # AccessToken.collection.update({ :_id=>token }, { :$set=>{ :last_access=>today, :prev_access=>last_access } })
            self.last_access = today
          end
        end

        # Revokes this access token.
        def revoke!
          self.revoked = Time.now.to_i
          # AccessToken.collection.update({ :_id=>token }, { :$set=>{ :revoked=>revoked } })
          # Client.collection.update({ :_id=>client_id }, { :$inc=>{ :tokens_revoked=>1 } })
        end

      end

    end
  end
end
