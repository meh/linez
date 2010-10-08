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

class Map
  attr_reader :linez

  def initialize (linez)
    @linez     = linez
    @positions = {}
  end

  def [] (x, y)
    @positions["#{x};#{y}"]
  end

  def []= (x, y, value)
    @positions["#{x};#{y}"] = value
  end

  def update (what)
    if what.is_a?(Linez::Line)
      self[what.x, what.y] = what.color
    end

    self
  end

  def send (line, what=nil)
    data = []

    if !what
      @positions.each {|position, value|
        position = position.match(/([\-+]?\d+);([\-+]?\d+)/)

        data.push(:x => position[1].to_i, :y => position[2].to_i, :color => value)
      }
    else
      if what.is_a? Linez::Line
        data.push(what.to_pixel)
      end
    end

    debug data.to_json

    line.send [:map, data]

    self
  end

  def broadcast (what, &block)
    @linez.each_value {|line|
      send(line, what) if !block_given? || block.call(line)
    }

    self
  end
end
