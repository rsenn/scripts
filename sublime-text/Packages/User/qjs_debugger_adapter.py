"""Registers the `qjs` debug type with the Debugger package: the adapter is `qjs-debugger -m dap` over stdio."""
from __future__ import annotations

import shutil

try:
	from Debugger.modules import dap
except ImportError:  # Debugger package not installed
	dap = None

if dap:

	class QuickJSInstaller(dap.AdapterInstaller):
		type = 'qjs'

	class QuickJS(dap.Adapter):
		type = 'qjs'
		docs = 'https://github.com/rsenn/qjs-debugger'

		# nothing to install, the adapter is the qjs-debugger script itself
		installer = QuickJSInstaller()

		async def start(self, console: dap.Console, configuration: dap.ConfigurationExpanded):
			# `adapter` in the configuration overrides the command; otherwise qjsm-debugger from PATH
			command = configuration.get('adapter')
			if not command:
				exe = shutil.which('qjsm-debugger') or '/usr/local/bin/qjsm-debugger'
				command = [exe, '-m', 'dap']
			return dap.StdioTransport(command, stderr=console.error)
