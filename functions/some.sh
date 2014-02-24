some()
{ 
    eval "while shift
  do
<<<<<<< HEAD
  case \"\$1\" in
    $1 ) return 0 ;;
=======
  case \"\`str_tolower \"\$1\"\`\" in
    $(str_tolower "$1") ) return 0 ;;
>>>>>>> 920a4a7eb2d8d4ebe7a624d237d7d9aad809de43
  esac
  done
  return 1"
}
