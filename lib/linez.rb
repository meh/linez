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

require 'lib/line'

class Linez < Hash
  def add_line (ws)
    while self[id = rand()]; end

    self[id] = Line.new(ws, id)
  end

  alias __delete delete

  def delete (line)
    __delete(line.id)
  end
end
