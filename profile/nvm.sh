if [ -e "$HOME/.nvm" ]; then
  . "$HOME/.nvm/nvm.sh"
  nvm use --delete-prefix v10
fi
