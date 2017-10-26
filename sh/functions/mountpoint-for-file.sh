mountpoint-for-file() {
  case `uname -o` in
    Msys*) (abspath=$(cygpath -am "$1"); drive=${abspath%%:*}:; cygpath -a "$drive") ;;
    *) (df "$1" | ${SED-sed} 1d | awkp 6)  ;;
  esac
}
