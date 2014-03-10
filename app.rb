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
    event_type = request['X-GitHub-Event']
    return unless payload && event_type

    message = case event_type.to_sym
    when :push
      commits = payload[:commits].map{|c|
        "#{c[:message]}\n  ->#{c[:url]}\n"
      }.join "\n"
      "#{payload[:repository][:url]}\n#{payload[:commits].size} commits pushed.\n\n#{commits}"
    else
      nil
    end

    ChatWork::Message.create room_id: params[:room_id], body: message if message
  end

end
