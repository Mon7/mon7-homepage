require 'rubygems'
require 'bundler/setup'
require './app'
use Rack::Deflater
run Sinatra::Application
