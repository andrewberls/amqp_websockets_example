#! /usr/bin/ruby

require 'sinatra/base'

class Application < Sinatra::Base
  get '/' do
    send_file File.join(settings.public_folder, 'index.html')
  end
end
