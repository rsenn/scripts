imatch_some()
{
    eval "while shift
  do
  case \"\`str_tolower \"\$1\"\`\" in
    $(str_tolower "$1") ) return 0 ;;
  esac
  done
  return 1"
}
