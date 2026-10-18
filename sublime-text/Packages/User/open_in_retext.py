import subprocess
import sublime_plugin


class OpenInRetextCommand(sublime_plugin.WindowCommand):
    def run(self):
        name = self.window.active_view().file_name()
        if name:
            subprocess.Popen(["retext", name], start_new_session=True)

    def is_enabled(self):
        return bool(self.window.active_view().file_name())
