# encoding: utf-8

require 'bundler'
Bundler.require

class App < Sinatra::Base
  get '/' do
    'Hi there.'
  end
end
