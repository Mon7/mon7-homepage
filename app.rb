# encoding: UTF-8
require 'sinatra'
require 'haml'

set :haml, :format => :html5, :escape_html => true
get '/' do
  haml :index, :locals =>{:name => 'index'}
end

get '/:page.html' do |page|
  pass unless File.exists? "./views/#{page}.haml"
  haml page.to_sym, :locals => {:name => page}
end

not_found do
  haml :'404'
end
