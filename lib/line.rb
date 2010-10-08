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

class Linez < Hash

class Line
  attr_reader :id, :x, :y, :color

  def initialize (socket, id)
    @socket = socket
    @id     = id

    @x = 0
    @y = 0

    @color = '#000000'
  end

  def color= (value)
    if value.match(/#([0-9a-fA-F]){6}/)
      @color = value
    else
      raise ArgumentError.new('Value has to be an hexadecimal color.')
    end
  end

  def position
    { :x => @x, :y => @y }
  end

  def near (position)
    (position[:x] - @x).abs <= 1 && (position[:y] - @y).abs <= 1
  end

  def move (position)
    @x, @y = position[:x], position[:y] if near(position)
  end

  def send (data)
    @socket.send data.to_json
  end

  def to_pixel
    { :x => @x, :y => @y, :color => @color }
  end

  def to_s
    "#<Line: #{@id} (#{@x};#{@y}) #{@color}>"
  end
end

end
