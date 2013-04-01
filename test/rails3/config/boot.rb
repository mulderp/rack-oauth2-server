unless defined?(ORM)
  ORM = (ENV["ORM"] || :active_record).to_sym
end

require 'rubygems'
require 'bundler/setup'

$:.unshift File.expand_path('../../../lib', __FILE__)
