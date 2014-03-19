# encoding: utf-8

require 'bundler'
Bundler.require
require 'json'

ChatWork.api_key = ENV['CHATWORK_API_TOKEN'] || ''

class CWHelper

  def self.tag_title title = nil
    title ? "[title]#{title}[/title]" : ''
  end

  def self.tag_info message, title = nil
    "[info]#{self.tag_title title}#{message}[/info]"
  end

  def self.tag_icon icon = :smile
    maps = {
      smile: ':)',
      sad: ':(',
      laugh: ':D',
      cool: '8-)',
      wow: ':o',
      wink: ';)',
      cry: ';(',
      oh: ':|',
      kiss: ';*',
      heart: 'h',
      flower: 'F',
      cracker: 'cracker',
      cake: '^',
      coffee: 'coffee',
      beer: 'beer',
      sweat: '(^^;)'
    }
    maps[icon] || icon
  end

end

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
        title = "[#{c['timestamp']}] #{c['committer']['name']} pushed."
        message = "#{c['message']}\n#{c['url']}"
        CWHelper.tag_info message, title
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

  post '/backuprb/:room_id' do
    status = params[:status]
    icon = case status.to_sym
           when :success then :cracker
           when :warning then :sweat
           else :cry
           end
    notify = "#{CWHelper.tag_icon icon}#{params[:message]}"
    message = CWHelper.tag_info notify, "Backup:#{status}"
    if message
      body = "[CHATWORK NOTIFIER] ヾ(〃l _ l)ﾉﾞ\n#{message}"
      ChatWork::Message.create room_id: params[:room_id], body: body
    end
  end

end
