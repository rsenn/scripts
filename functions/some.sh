some()
{ 
    eval "while shift
  do
  case \"\`str_tolower \"\$1\"\`\" in
    $(str_tolower "$1") ) return 0 ;;
  esac
  done
  return 1"
}
some()
{ 
    eval "while shift
  do
  case \"\$1\" in
    $1 ) return 0 ;;
  esac
  done
  return 1"
}
some()
{ 
    eval "while shift
  do
  case \"\$1\" in
    $1 ) return 0 ;;
  esac
  done
  return 1"
}
