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

load 'lib/map.rb'
load 'lib/linez.rb'

map   = Map.new
linez = Linez.new

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

  EventMachine::WebSocket.start(:host => '0.0.0.0', :port => 8080) {|ws|
    ws.onopen {
      line = linez.add_line(ws)
  
      ws.onmessage {|msg|
        msg = JSON.parse(msg, :symbolize_names => true) rescue break
  
        break unless msg.is_a?(Array)
  
        command = msg[0]
        data    = msg[1]
  
        case command
          when :move
            if !line.near(data)
              ws.send([:error, { :message => 'HAAAAAAAAAAAAAX', :code => 20 }].to_json)
              break
            end
  
            if !line.move(data)
              ws.send([:error, { :message => 'Something went wrong in your movement.', :code => 21 }].to_json)
              break
            end
  
            map.update(line).broadcast(line.position)
  
          when :set
            what = data[0]
            data = data[1]
  
            case what
              when :color
                line.color = data
            end
        end
      }
  
      ws.onclose {
        linez.delete(line)
      }
    }
  }

  Application.run!(:port => 3000)
}
