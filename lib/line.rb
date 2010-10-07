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
  attr_accessor :color

  attr_reader :id, :x, :y

  def initialize (ws, id)
    @ws = ws
    @id = id

    @x = 0
    @y = 0
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
end

end
