SUBLIME_CONFIG ?= $(HOME)/.config/sublime-text
DEST := $(SUBLIME_CONFIG)/Packages/User
PACKAGES := $(SUBLIME_CONFIG)/Packages

.PHONY: install
install:
	mkdir -p "$(DEST)/Themes"
	cp User/Themes/Rastafarian.sublime-color-scheme "$(DEST)/Themes/"
	cp User/rainbow_parens.py "$(DEST)/"
	cp User/rastafarian_macro_names.py "$(DEST)/"
	cp "User/C++.sublime-settings" "$(DEST)/"
	@echo "Installed Rastafarian scheme + plugins into $(DEST)"
	@echo "Removing conflicting C/C++ syntax packages (C11, C++11, C Improved)..."
	@found=$$(find "$(PACKAGES)" \( -name "C11.*" -o -name "C++11.*" -o -name "C Improved.*" \)); \
	if [ -n "$$found" ]; then \
		echo "$$found" | while read -r p; do rm -rf "$$p"; echo "Removed $$p"; done; \
	else \
		echo "None found."; \
	fi
	@echo "Done. Restart Sublime Text, then Preferences > Color Scheme... > Rastafarian"
