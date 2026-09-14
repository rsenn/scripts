import sublime
import sublime_plugin

OPENERS = "([{"
CLOSERS = ")]}"
MAX_LEVELS = 6
SCOPE_PREFIX = "rainbow.bracket.level"
MAX_FILE_SIZE = 500000
SKIP_SELECTOR = "string, comment"


def _compute_levels(view):
    text = view.substr(sublime.Region(0, view.size()))
    levels = [[] for _ in range(MAX_LEVELS)]
    depth = 0
    for i, ch in enumerate(text):
        if ch not in OPENERS and ch not in CLOSERS:
            continue
        if view.match_selector(i, SKIP_SELECTOR):
            continue
        if ch in OPENERS:
            levels[depth % MAX_LEVELS].append(sublime.Region(i, i + 1))
            depth += 1
        else:
            depth = max(depth - 1, 0)
            levels[depth % MAX_LEVELS].append(sublime.Region(i, i + 1))
    return levels


def _apply(view):
    if view.is_loading() or view.size() > MAX_FILE_SIZE:
        return
    levels = _compute_levels(view)
    for lvl in range(MAX_LEVELS):
        key = "rainbow_paren_lvl_%d" % lvl
        if levels[lvl]:
            view.add_regions(
                key,
                levels[lvl],
                scope=SCOPE_PREFIX + str(lvl),
                flags=sublime.DRAW_NO_FILL | sublime.DRAW_NO_OUTLINE,
            )
        else:
            view.erase_regions(key)


class RainbowParensListener(sublime_plugin.ViewEventListener):
    def on_activated_async(self):
        _apply(self.view)

    def on_load_async(self):
        _apply(self.view)

    def on_modified_async(self):
        _apply(self.view)


def plugin_loaded():
    for window in sublime.windows():
        for view in window.views():
            _apply(view)
