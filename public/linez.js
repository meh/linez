/* Copyleft meh. [http://meh.doesntexist.org | meh@paranoici.org]
 *
 * This file is part of linez.
 *
 * linez is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published
 * by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * linez is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with linez. If not, see <http://www.gnu.org/licenses/>.
 ****************************************************************************/

Event.observe(document, 'dom:loaded', function () {
    if (!window.WebSocket) {
      alert('NO WEBSOCKETZ, WUT');
      return;
    }

    window.linez = new Linez;
});

Keys = {
    Left:  37,
    Up:    38,
    Right: 39,
    Down:  40
};

Linez = Class.create({
    initialize: function () {
        this.map = new Linez.Map(this);

        this.connection = new Linez.Connection(this);

        this.line = new Linez.Line(this);
        this.line.draw();

        this.keys = {};

        Event.observe(document, 'keydown', function (event) {
            this.keys[event.keyCode] = true;
            this.handle();
        }.bind(this));

        Event.observe(document, 'keyup', function (event) {
            delete this.keys[event.keyCode];
            this.handle();
        }.bind(this));
    },

    handle: function () {
        if (Object.keys(this.keys).length == 0) {
            return;
        }

        if (this.keys[Keys.Up]) {
            this.line.move(0, -1);
        }

        if (this.keys[Keys.Down]) {
            this.line.move(0, 1);
        }

        if (this.keys[Keys.Left]) {
            this.line.move(-1, 0);
        }

        if (this.keys[Keys.Right]) {
            this.line.move(1, 0);
        }

        this.line.draw().send('location');
    }
});

Linez.Line = Class.create({
    initialize: function (linez) {
        this.linez = linez;

        this.color = '#000000';
        this.x     = 0;
        this.y     = 0;

        this.left = this.x - (this.linez.map.width / 2).floor();
        this.top  = this.y - (this.linez.map.height / 2).floor();

        Event.observe(document, 'resize', function () {
            this.left = this.x - (this.linez.map.width / 2).floor();
            this.top  = this.y - (this.linez.map.height / 2).floor();

            this.redraw();
        }.bind(this));
    },

    move: function (x, y) {
        this.x += x;
        this.y += y;
    },

    draw: function () {
        this.linez.map.update(this.toPixel()).render()
        return this;
    },

    relative: function (pixel) {
        return {
            color: pixel.color,

            x: pixel.x - this.left,
            y: pixel.y - this.top
        };
    },

    send: function (what) {
        if (what == 'location') {
            if (this.last && this.x == this.last.x && this.y == this.last.y) {
                return;
            }
            else {
                this.last = { x: this.x, y: this.y };
            }
    
            this.linez.connection.send(['move', this.last]);
        }
        else if (what == 'color') {
            this.linez.connection.send(['set', ['color', this.color]]);
        }
    },

    toPixel: function () {
        return {
            color: this.color,

            x: this.x,
            y: this.y
        };
    }
});

Linez.Map = Class.create({
    initialize: function (linez, canvas) {
        this.linez = linez;

        this.canvas             = new Element('canvas', { id: 'canvas' });
        this.canvas.width       = this.width  = document.viewport.getWidth();
        this.canvas.height      = this.height = document.viewport.getHeight();
        this.canvas.globalAlpha = 0;

        this.context = this.canvas.getContext('2d');

        this.positions = {};

        document.body.appendChild(this.canvas);

        Event.observe(window, 'resize', function () {
            this.canvas.width  = this.width  = document.viewport.getWidth();
            this.canvas.height = this.height = document.viewport.getHeight();
        }.bind(this));
    },

    position: function (x, y, value) {
        if (!Object.isObject(this.positions[x])) {
            this.positions[x] = {};
        }

        if (Object.isUndefined(value)) {
            return this.positions[x][y];
        }
        else {
            return this.positions[x][y] = value;
        }
    },

    pixels: function (range) {
        if (!range) {
            range = {
                from: { x: this.linez.line.left, y: this.linez.line.top },
                to:   { x: this.linez.line.left + this.width, y: this.linez.line.top + this.height }
            };
        }

        var result = [];

        for (var x = range.from.x; x < range.to.x; x++) {
            if (!Object.isObject(this.positions[x])) {
                continue;
            }

            for (var y = range.from.y; y < range.to.y; y++) {
                if (this.positions[x][y]) {
                    result.push(this.positions[x][y]);
                }
            }
        }

        return this.renderizable(result);
    },

    renderizable: function (value) {
        if (Object.isArray(value)) {
            value.render = function (force) {
                this.array.each(function (pixel) {
                    this.map.draw(pixel, force);
                }, this);
            }.bind({ array: value, map: this });
        }
        else if (Object.isObject(value)) {
            value.render = function (force) {
                this.map.draw(this.pixel, force);
            }.bind({ pixel: value, map: this });
        }

        return value;
    },

    update: function (data) {
        if (Object.isArray(data)) {
            data.each(function (pixel) {
                this.position(pixel.x, pixel.y, Object.extend(pixel, { old: false }));
            }, this);
        }
        else {
            this.position(data.x, data.y, Object.extend(data, { old: false }));
        }

        return this.renderizable(data);
    },

    draw: function (pixel, force) {
        if (!pixel || pixel.old && !force) {
            return;
        }
        else {
            pixel.old = true;
        }

        pixel = this.linez.line.relative(pixel);

        this.context.fillStyle = pixel.color;
        this.context.fillRect(pixel.x, pixel.y, 1, 1);
    },

    render: function (range, force) {
        if (Object.is(Linez.Line, range)) {
            this.draw(range, force);
        }
        else {
            this.pixels(range).render()
        }

        return this;
    },

    redraw: function (range) {
        this.render(range, true);
    }
});

Linez.Connection = Class.create({
    initialize: function (linez) {
        this.linez = linez;

        this.socket = new WebSocket("ws://#{host}:#{port}".interpolate({
            host: window.location.hostname,
            port: 8080
        }));

        this.socket.onopen = function () {
            this.socket.onmessage = function (event) {
                this.handle(miniLOL.JSON.unserialize(event.data));
            }.bind(this);

            this.socket.onclose = function (event) {
                alert('The server closed the connection.');
            }.bind(this);

            this.socket.onerror = function (event) {
                alert(event);
            }.bind(this);

            this.send = function (data) {
                this.socket.send(miniLOL.JSON.serialize(data));
            }
        }.bind(this);
    },

    handle: function (data) {
        var what = data[0];
        var data = data[1];

        switch (what) {
            case 'map': this.linez.map.update(data).render(); break;
        }
    },

    send: Function.empty
});
