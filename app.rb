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
    event_type = request.env['HTTP_X_GITHUB_EVENT']
    puts "event type: #{event_type}"
    return unless payload && event_type

    message = case event_type.to_sym
    when :push
      payload['commits'].map{|c|
        meta = "[#{c['timestamp']}] #{c['committer']['name']}"
        url = c['url']
        title = "[title]#{meta}[/title]"
        "[info]#{meta}\n#{message}\n#{url}[/info]"
      }.join "\n"
    else
      nil
    end

    puts "message: #{message}"
    if message
      body = "[CHATWORK NOTIFIER] ヾ(〃l _ l)ﾉﾞ\n#{message}"
      ChatWork::Message.create room_id: params[:room_id], body: body
    end
  end

end
