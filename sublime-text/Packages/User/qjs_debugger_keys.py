"""Always-enabled front for the Debugger package's `debugger` command.

Debugger's step/continue actions report is_enabled() == False unless the program is paused, and
Sublime then lets the key fall through to the next binding (F10 -> menu bar, F11 -> full screen).
Binding the keys to this command swallows them in every state.
"""
import sublime_plugin


class QjsDebuggerKeyCommand(sublime_plugin.WindowCommand):
	def run(self, action, **kwargs):
		self.window.run_command('debugger', {'action': action, **kwargs})

	def is_enabled(self, **kwargs):
		return True
