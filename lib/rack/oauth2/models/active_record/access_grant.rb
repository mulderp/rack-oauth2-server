module Rack
  module OAuth2
    class Server

      # The access grant is a nonce, new grant created each time we need it and
      # good for redeeming one access token.
      class AccessGrant < ActiveRecord::Base
        class << self
          # Find AccessGrant from authentication code.
          def from_code(code)
            # Server.new_instance self, collection.find_one({ :_id=>code, :revoked=>nil })
            AccessGrant.where(:id => code, :revoked => nil).first
          end

          # Create a new access grant.
          def generate(identity, client, scope, redirect_uri = nil, expires = nil)
            raise ArgumentError, "Identity must be String or Integer" unless String === identity || Integer === identity
            scope = Utils.normalize_scope(scope) & YAML.load(client.scope) # Only allowed scope
            expires_at = Time.now.to_i + (expires || 300)
            fields = { :identity=>identity, :scope=>scope,
                       :client_id=>client.id, :redirect_uri=>client.redirect_uri || redirect_uri,
                       :created_at=>Time.now.to_i, :expires_at=>expires_at, :granted_at=>nil,
                       :access_token=>nil, :revoked=>nil }
            AccessGrant.create fields
          end

        end

        # Authorization code. We are nothing without it.
        alias :code :id
        # The identity we authorized access to.
        # Client that was granted this access token.
        # Redirect URI for this grant.
        # The scope requested in this grant.
        # Does what it says on the label.
        # Tells us when (and if) access token was created.
        # Tells us when this grant expires.
        # Access token created from this grant. Set and spent.
        # Timestamp if revoked.

        # Authorize access and return new access token.
        #
        # Access grant can only be redeemed once, but client can make multiple
        # requests to obtain it, so we need to make sure only first request is
        # successful in returning access token, futher requests raise
        # InvalidGrantError.
        def authorize!(expires_in = nil)
          raise InvalidGrantError, "You can't use the same access grant twice" if self.access_token || self.revoked
          client = Client.where(id: client_id).first or raise InvalidGrantError
          puts client.inspect
          puts "*******"
          access_token = AccessToken.get_token_for(identity, client, scope, expires_in)
          self.access_token = access_token.token
          self.granted_at = Time.now.to_i
          
         # self.class.collection.update({ :_id=>code, :access_token=>nil, :revoked=>nil }, { :$set=>{ :granted_at=>granted_at, :access_token=>access_token.token } }, :safe=>true)
         # reload = self.class.collection.find_one({ :_id=>code, :revoked=>nil }, { :fields=>%w{access_token} })
          raise InvalidGrantError unless reload && reload["access_token"] == access_token.token
          return access_token
        end

        def revoke!
          self.revoked = Time.now.to_i
         #  self.class.collection.update({ :_id=>code, :revoked=>nil }, { :$set=>{ :revoked=>revoked } })
        end

      end

    end
  end
end
