case "`type -t cols`" in
  "function") unset -f cols ;;
  "alias") unalias cols ;;
esac

if [ -z "`type -t cols`" ]; then
  cols() {
    column -c $COLUMNS
  }
fi
