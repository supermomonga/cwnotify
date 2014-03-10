# encoding: utf-8

require 'bundler'
Bundler.require
require 'json'

ChatWork.api_key = ENV['CHATWORK_API_TOKEN'] || ''

class App < Sinatra::Base

  get '/' do
    'Hi there.'
  end

  post '/github/:room_id' do
    payload = params[:payload] ? JSON.parse(params[:payload]) : nil
    if payload
      ChatWork::Message.create(room_id: params[:room_id], body: payload.to_s)
    end
  end

end
