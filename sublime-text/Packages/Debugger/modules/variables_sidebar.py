from __future__ import annotations
from typing import TYPE_CHECKING

import sublime

from . import core
from . import ui

from .settings import Settings
from .views.tabbed import TabbedViewContainer
from .views.variables import VariablesTabbedView

if TYPE_CHECKING:
	from .debugger import Debugger


def wanted(window: sublime.Window) -> bool:
	"""`variables_sidebar` in Debugger.sublime-settings, and a group to put the view in (see `group`)."""
	if not sublime.load_settings('Debugger.sublime-settings').get('variables_sidebar', False):
		return False

	return window.num_groups() > 1


def group(window: sublime.Window) -> int:
	"""`variables_sidebar_group` (default -1: the last group, where an outline view usually is)."""
	index = sublime.load_settings('Debugger.sublime-settings').get('variables_sidebar_group', -1)
	count = window.num_groups()
	if not isinstance(index, int) or index >= count:
		return count - 1
	return index % count


class VariablesSidebar(core.Dispose):
	"""Watched expressions and variables in an ordinary view in another group of the window,
	instead of the right half of the callstack panel."""

	def __init__(self, debugger: Debugger) -> None:
		super().__init__()
		self.debugger = debugger
		window = debugger.window

		previous_view = window.active_view()
		previous_group = window.active_group()

		self.view = window.new_file()
		self.view.set_scratch(True)
		self.view.set_name('Variables')
		self.view.run_command('insert', {'characters': '‌'})
		self.view.set_read_only(True)

		settings = self.view.settings()
		settings.set('debugger', id(debugger))
		settings.set('debugger.variables_sidebar', True)
		settings.set('draw_unicode_white_space', 'none')
		settings.set('context_menu', 'DebuggerWidget.sublime-menu')
		settings.set('rulers', [])
		settings.set('gutter', False)
		settings.set('margin', 0)
		settings.set('line_padding_top', 3)
		settings.set('scroll_past_end', False)
		settings.set('word_wrap', False)
		settings.set('highlight_line', False)
		settings.set('line_numbers', False)
		settings.set('internal_font_scale', Settings.internal_font_scale)
		settings.set('internal_width_modifier', Settings.internal_width_modifier)
		if Settings.font_size:
			settings.set('font_size', Settings.font_size)

		window.set_view_index(self.view, group(window), len(window.views_in_group(group(window))))

		# the new view took the focus: give it back
		window.focus_group(previous_group)
		if previous_view and previous_view.is_valid():
			window.focus_view(previous_view)

		with ui.Phantom(self.view, 0, name='Variables') as phantom:
			self.dispose_add(phantom)

			with TabbedViewContainer(width_additional=-2):
				VariablesTabbedView(debugger)

		self.dispose_add(self._close)

	def _close(self) -> None:
		if self.view.is_valid():
			self.view.set_scratch(True)
			self.view.close()
