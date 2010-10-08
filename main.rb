#! /usr/bin/env ruby
#--
# Copyleft meh. [http://meh.doesntexist.org | meh@paranoici.org]
#
# This file is part of linez.
#
# linez is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# linez is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with linez. If not, see <http://www.gnu.org/licenses/>.
#++

require 'sinatra/base'
require 'padrino-core/application/routing'
require 'padrino-core/application/rendering'
require 'em-websocket'
require 'json'
require 'haml'

def debug (*args)
  if ENV['DEBUG']
    puts *args
  end
end

load 'lib/map.rb'
load 'lib/linez.rb'

linez = Linez.new
map   = Map.new(linez)

EventMachine.run {
  class Application < Sinatra::Application
    register Padrino::Routing
    register Padrino::Rendering

    set :public, File.dirname(__FILE__) + '/public'
    set :views, File.dirname(__FILE__) + '/public'

    get :index do
      render :index
    end
  end

  EventMachine::WebSocket.start(:host => '0.0.0.0', :port => 8080) {|socket|
    socket.onopen {
      line = linez.add_line(socket)

      debug "#{line.inspect}: connected."

      map.send(line)
  
      socket.onmessage {|msg|
        begin
          msg = JSON.parse(msg, :symbolize_names => true)
        rescue
          debug $!
        end

        debug "#{line.inspect}: #{msg.inspect}"
  
        next unless msg.is_a?(Array)
  
        command = msg[0].to_sym
        data    = msg[1]
  
        case command
          when :move
            if !line.near(data)
              line.send([:error, { :message => 'HAAAAAAAAAAAAAX', :code => 20 }].to_json)
              next
            end
  
            if !line.move(data)
              line.send([:error, { :message => 'Something went wrong in your movement.', :code => 21 }].to_json)
              next
            end

            map.update(line).broadcast(line) {|on|
              on != line
            }
  
          when :set
            what = data[0].to_sym
            data = data[1]
  
            case what
              when :color
                begin
                  line.color = data
                rescue
                  line.send([:error, { :message => 'What you inserted is not an hexadecimal color.', :code => 11 }].to_json)
                end
            end
        end rescue nil
      }

      socket.onerror {|reason|
        debug reason.inspect
      }
  
      socket.onclose {
        linez.delete(line)

        debug "#{line.inspect}: disconnected."
      }
    }
  }

  Application.run!(:port => 3000)
}
