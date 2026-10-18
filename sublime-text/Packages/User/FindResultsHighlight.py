import sublime
import sublime_plugin

SYNTAX = 'Packages/User/Find Results Highlight.sublime-syntax'


class FindResultsHighlight(sublime_plugin.EventListener):
    def on_load_async(self, view):
        self.apply(view)

    def on_activated_async(self, view):
        self.apply(view)

    def apply(self, view):
        syn = view.settings().get('syntax') or ''
        if 'Find Results' in syn and syn != SYNTAX:
            view.assign_syntax(SYNTAX)
