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
    var canvas = new Element('canvas', { id: 'canvas' });

    var resize = function () {
        canvas.width  = document.viewport.getWidth();
        canvas.height = document.viewport.getHeight();
    }

    document.body.appendChild(canvas);

    Event.observe(window, 'resize', resize);
    resize();

    Linez.start(canvas);
});

Linez = (function () {
    var _canvas;
    var _ctx;

    function start (canvas) {
        _canvas = canvas;
        _ctx    = canvas.getContext('2d');
    }

    return {
        start: start
    };
})();
