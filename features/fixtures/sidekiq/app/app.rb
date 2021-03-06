require 'bundler'
Bundler.require

Bugsnag.configure do |conf|
  puts "Configuring `api_key` to #{ENV['BUGSNAG_API_KEY']}"
  conf.api_key = ENV['BUGSNAG_API_KEY']
  puts "Configuring `endpoint` to #{ENV['BUGSNAG_ENDPOINT']}"
  conf.endpoint = ENV['BUGSNAG_ENDPOINT']
end

Sidekiq.configure_client do |config|
  config.redis = { :url => 'redis://redis:6379', :size => 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { :url => 'redis://redis:6379' }
end

class HandledError
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform
    Bugsnag.notify(RuntimeError.new("Handled"))
  end
end

class UnhandledError
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform
    raise RuntimeError.new("Unhandled")
  end
end