require "rack/oauth2/server"
require "rack/oauth2/rails" if defined?(Rails)
require "rack/oauth2/server/railtie" if defined?(Rails::Railtie)
