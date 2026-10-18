import re
import sublime
import sublime_plugin

DIRECTIVE_RE = re.compile(r"#\s*(?:ifndef|ifdef|undef)\s+([A-Za-z_]\w*)")
DEFINED_RE = re.compile(r"\bdefined\b(?:\s*\(\s*([A-Za-z_]\w*)\s*\)|\s+([A-Za-z_]\w*))?")
MACRO_SCOPE = "entity.name.constant.preprocessor"
MAX_FILE_SIZE = 500000
REGION_KEY = "rastafarian_preproc_macro_name"


def _valid(view, start):
    return view.match_selector(start, "meta.preprocessor") and not view.match_selector(
        start, "comment, string"
    )


def _apply(view):
    if view.is_loading() or view.size() > MAX_FILE_SIZE:
        return
    text = view.substr(sublime.Region(0, view.size()))
    regions = []
    for m in DIRECTIVE_RE.finditer(text):
        start, end = m.span(1)
        if _valid(view, start):
            regions.append(sublime.Region(start, end))
    for m in DEFINED_RE.finditer(text):
        start, end = m.span()
        if not _valid(view, start):
            continue
        regions.append(sublime.Region(start, start + len("defined")))
        name_span = m.span(1) if m.group(1) else m.span(2)
        if name_span[0] != -1:
            regions.append(sublime.Region(*name_span))
    if regions:
        view.add_regions(
            REGION_KEY,
            regions,
            scope=MACRO_SCOPE,
            flags=sublime.DRAW_NO_FILL | sublime.DRAW_NO_OUTLINE,
        )
    else:
        view.erase_regions(REGION_KEY)


class RastafarianMacroNameListener(sublime_plugin.ViewEventListener):
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
