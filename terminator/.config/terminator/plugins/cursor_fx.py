"""Ghostty-style cursor effects for Terminator.

Ports the two shaders from ghostty/.config/ghostty/shaders
(sahaj-b/cursor-shaders, MIT, see the LICENSE there): cursor_warp.glsl
smears the cursor along its path when it jumps, ripple_cursor.glsl rings
out where it lands.

VTE has no shader hook, so the effects are painted with Cairo on top of each
terminal after VTE draws it. Enable with `enabled_plugins = CursorFX` under
[global_config].
"""
import math
import os

import cairo
from gi.repository import GLib, Gdk

import terminatorlib.plugin as plugin
from terminatorlib.terminator import Terminator

AVAILABLE = ['CursorFX']

# warp, same values as cursor_warp.glsl
WARP_DURATION = 0.2       # seconds
TRAIL_SIZE = 0.8          # 0 = all corners move together, 1 = leading corners jump instantly
MIN_DISTANCE = 1.5        # shortest jump that gets a trail, in cursor heights
TRAIL_THICKNESS = 1.0     # trail height as a fraction of the cursor height
TRAIL_THICKNESS_X = 0.9   # trail width as a fraction of the cursor width

# ripple, same values as ripple_cursor.glsl. Ghostty fires it only when the
# cursor changes shape (vim block <-> bar), which VTE does not report, so it is
# off to match. True fires it on the same jumps as the warp instead.
RIPPLE = False
RIPPLE_DURATION = 0.15
RIPPLE_MAX_RADIUS = 0.025  # fraction of the terminal height
RIPPLE_THICKNESS = 0.01    # fraction of the terminal height
RIPPLE_BLUR = 3.0          # px
RIPPLE_COLOR = (0.626, 0.634, 0.694)  # the shader's linear (0.35, 0.36, 0.44) in sRGB

# CURSOR_FX_SLOWMO=10 plays the animations 10x slower, for tuning.
SLOWMO = float(os.environ.get('CURSOR_FX_SLOWMO', '1'))


def ease_out_circ(t):
    return math.sqrt(max(0.0, 1.0 - (t - 1.0) ** 2))


def smoothstep(edge0, edge1, x):
    t = min(max((x - edge0) / (edge1 - edge0), 0.0), 1.0)
    return t * t * (3.0 - 2.0 * t)


def sign(v):
    return (v > 0) - (v < 0)


def center(rect):
    x, y, w, h = rect
    return x + w / 2, y + h / 2


class CursorFX(plugin.Plugin):
    capabilities = ['cursor_fx']

    def __init__(self):
        plugin.Plugin.__init__(self)
        self.effects = []
        # Terminator has no plugin hook for new terminals, so wrap the
        # registration every terminal goes through.
        self.register_terminal = Terminator.register_terminal
        fx = self

        def register_terminal(terminator, terminal):
            fx.register_terminal(terminator, terminal)
            GLib.idle_add(fx.attach, terminal)  # its vte is created after this

        Terminator.register_terminal = register_terminal
        for terminal in Terminator().terminals:
            GLib.idle_add(self.attach, terminal)

    def attach(self, terminal):
        if getattr(terminal, 'vte', None) and not hasattr(terminal, 'cursor_fx'):
            terminal.cursor_fx = CursorEffects(terminal)
            self.effects.append(terminal.cursor_fx)
        return False

    def unload(self):
        Terminator.register_terminal = self.register_terminal
        for effects in self.effects:
            effects.detach()
        self.effects = []


class CursorEffects:
    """Warp and ripple for one terminal."""

    def __init__(self, terminal):
        self.terminal = terminal
        self.vte = terminal.vte
        self.top = 0
        self.top_key = None
        self.rect = self.cursor_rect()
        self.prev = self.rect
        self.moved_at = 0.0
        self.color = (1.0, 1.0, 1.0)
        self.visible = False
        self.probing = False
        self.tick = None
        self.handlers = [
            self.vte.connect('cursor-moved', self.on_cursor_moved),
            self.vte.connect_after('draw', self.on_draw),
        ]

    def detach(self):
        for handler in self.handlers:
            self.vte.disconnect(handler)
        if self.tick is not None:
            self.vte.remove_tick_callback(self.tick)
            self.invalidate()
        del self.terminal.cursor_fx

    def cursor_rect(self):
        vte = self.vte
        col, row = vte.get_cursor_position()
        adj = vte.get_vadjustment()
        key = (row, adj.get_value(), adj.get_upper())
        if key != self.top_key:  # typing along a line never pays for this
            self.top_key = key
            self.top = self.visible_top()
        style = vte.get_style_context()
        pad = style.get_padding(style.get_state())
        w, h = vte.get_char_width(), vte.get_char_height()
        return (pad.left + col * w, pad.top + (row - self.top) * h, w, h)

    def visible_top(self):
        """Absolute row number of the top visible line."""
        # The cursor row is absolute, but the vadjustment counts from the
        # oldest line still in the scrollback, so the two drift apart once
        # `clear` drops the scrollback or it fills up. get_text() tags every
        # visible cell with its absolute row (~0.1-2 ms, by screen content).
        _text, attrs = self.vte.get_text(None, None)
        if attrs:
            return attrs[0].row
        return self.vte.get_vadjustment().get_value()

    def on_screen(self, rect):
        return 0 <= rect[1] < self.vte.get_allocated_height()

    def cursor_color(self):
        config = self.terminal.config
        rgba = Gdk.RGBA()
        rgba.parse(config['foreground_color'] if config['cursor_color_fg']
                   else config['cursor_color'])
        return rgba.red, rgba.green, rgba.blue

    def is_jump(self):
        if not (self.on_screen(self.prev) and self.on_screen(self.rect)):
            return False  # scrolled back while the cursor moved
        (x0, y0), (x1, y1) = center(self.prev), center(self.rect)
        return math.hypot(x1 - x0, y1 - y0) > self.rect[3] * MIN_DISTANCE

    def elapsed(self):
        return (GLib.get_monotonic_time() / 1e6 - self.moved_at) / SLOWMO

    def on_cursor_moved(self, vte):
        rect = self.cursor_rect()
        if rect == self.rect:
            return  # output scrolled, but the cursor stayed put on screen
        if self.tick is not None:
            self.invalidate()  # wipe the trail this move replaces
        # Like Ghostty, every move restarts the animation from the last
        # position, so a small move cancels a running trail.
        self.prev, self.rect = self.rect, rect
        self.moved_at = GLib.get_monotonic_time() / 1e6
        if self.is_jump():
            self.color = self.cursor_color()
            self.visible = self.cursor_painted()
            if self.visible and self.tick is None:
                self.tick = vte.add_tick_callback(self.on_tick)

    def on_tick(self, vte, frame_clock):
        self.invalidate()
        duration = max(WARP_DURATION, RIPPLE_DURATION if RIPPLE else 0)
        if self.visible and self.is_jump() and self.elapsed() < duration:
            return True
        self.tick = None  # this last redraw paints the frame without effects
        return False

    def invalidate(self):
        """Queue a redraw of everything the animation can paint."""
        height = self.vte.get_allocated_height()
        reach = ((RIPPLE_MAX_RADIUS + RIPPLE_THICKNESS / 2) * height + RIPPLE_BLUR) if RIPPLE else 0
        (px, py, pw, ph), (cx, cy, cw, ch) = self.prev, self.rect
        mx, my = center(self.rect)
        left = min(px, cx, mx - reach) - 2
        top = min(py, cy, my - reach) - 2
        right = max(px + pw, cx + cw, mx + reach) + 2
        bottom = max(py + ph, cy + ch, my + reach) + 2
        self.vte.queue_draw_area(int(left), int(top),
                                 int(math.ceil(right - left)),
                                 int(math.ceil(bottom - top)))

    def on_draw(self, vte, cr):
        if self.probing or self.tick is None or not self.visible or not self.is_jump():
            return False
        t = self.elapsed()
        if t < WARP_DURATION:
            self.draw_warp(cr, t)
        if RIPPLE and t < RIPPLE_DURATION:
            self.draw_ripple(cr, t / RIPPLE_DURATION)
        return False

    def cursor_painted(self):
        """True if VTE paints the cursor, False if an app has hidden it.

        Apps hide the cursor (DECTCEM) while they redraw, Claude Code keeps
        it hidden, and VTE does not report it. Ghostty draws no trail for a
        hidden cursor, so have VTE draw just the cursor cell into a small
        image and look for cursor-colored pixels: a block, bar, underline or
        hollow cursor all leave some. Reading the on-screen surface back
        instead stalls on the X server for up to ~12 ms.
        """
        x, y, w, h = self.rect
        m = 2  # the hollow (unfocused) cursor is outlined 1px outside the cell
        surface = cairo.ImageSurface(cairo.FORMAT_RGB24, int(w) + 2 * m, int(h) + 2 * m)
        cr = cairo.Context(surface)
        cr.translate(m - x, m - y)
        cr.rectangle(x - m, y - m, w + 2 * m, h + 2 * m)
        cr.clip()
        self.probing = True
        try:
            self.vte.draw(cr)
        finally:
            self.probing = False
        surface.flush()
        data, stride = bytes(surface.get_data()), surface.get_stride()
        r, g, b = (int(c * 255) for c in self.color)
        hits = 0
        for py in range(surface.get_height()):
            row = py * stride
            for px in range(surface.get_width()):
                i = row + px * 4  # BGRx
                if abs(data[i + 2] - r) < 40 and abs(data[i + 1] - g) < 40 and abs(data[i] - b) < 40:
                    hits += 1
                    if hits >= 3:
                        return True
        return False

    def draw_warp(self, cr, t):
        def corners(rect):
            mx, my = center(rect)
            hw = rect[2] / 2 * TRAIL_THICKNESS_X
            hh = rect[3] / 2 * TRAIL_THICKNESS
            return {'tl': (mx - hw, my - hh), 'tr': (mx + hw, my - hh),
                    'br': (mx + hw, my + hh), 'bl': (mx - hw, my + hh)}

        start, end = corners(self.prev), corners(self.rect)
        (x0, y0), (x1, y1) = center(self.prev), center(self.rect)
        sx, sy = sign(x1 - x0), sign(y0 - y1)  # y up, as in the shader

        # Corners facing the move lead (short duration), corners behind trail.
        lead = WARP_DURATION * (1.0 - TRAIL_SIZE)
        side = (lead + WARP_DURATION) / 2

        def duration(dot):
            return lead if dot > 0.5 else side if dot > -0.5 else WARP_DURATION

        dots = {'tl': -sx + sy, 'tr': sx + sy, 'br': sx - sy, 'bl': -sx - sy}
        durations = {k: duration(d) for k, d in dots.items()}
        if sx < 0:  # the leading vertical edge moves as one rail
            durations['tl'] = durations['bl'] = duration((dots['tl'] + dots['bl']) / 2)
        if sx > 0:
            durations['tr'] = durations['br'] = duration((dots['tr'] + dots['br']) / 2)

        cr.save()
        # Punch out the cursor cell so the real cursor stays on top.
        x1, y1, x2, y2 = cr.clip_extents()
        cr.rectangle(x1, y1, x2 - x1, y2 - y1)
        cr.rectangle(*self.rect)
        cr.set_fill_rule(cairo.FILL_RULE_EVEN_ODD)
        cr.clip()
        cr.set_fill_rule(cairo.FILL_RULE_WINDING)
        for i, k in enumerate(('tl', 'tr', 'br', 'bl')):
            p = ease_out_circ(min(t / durations[k], 1.0))
            (ax, ay), (bx, by) = start[k], end[k]
            (cr.move_to if i == 0 else cr.line_to)(ax + (bx - ax) * p, ay + (by - ay) * p)
        cr.close_path()
        cr.set_source_rgb(*self.color)
        cr.fill()
        cr.restore()

    def draw_ripple(self, cr, p):
        height = self.vte.get_allocated_height()
        radius = ease_out_circ(p) * RIPPLE_MAX_RADIUS * height
        half = RIPPLE_THICKNESS * height / 2
        fade = 1.0 - p * (2.0 - p)
        outer = radius + half + RIPPLE_BLUR
        inner = max(0.0, radius - half - RIPPLE_BLUR)
        cx, cy = center(self.rect)
        # Sample the shader's ring falloff into gradient stops.
        gradient = cairo.RadialGradient(cx, cy, 0, cx, cy, outer)
        steps = 16
        for i in range(steps + 1):
            d = inner + (outer - inner) * i / steps
            ring = abs(d - radius) - half
            alpha = (1.0 - smoothstep(-RIPPLE_BLUR, RIPPLE_BLUR, ring)) * fade
            gradient.add_color_stop_rgba(d / outer, *RIPPLE_COLOR, alpha)
        cr.save()
        cr.arc(cx, cy, outer, 0, 2 * math.pi)
        cr.set_source(gradient)
        cr.fill()
        cr.restore()
