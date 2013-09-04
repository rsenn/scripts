match_some()
{ 
    eval "while shift
  do
  case \"\$1\" in
    $1 ) return 0 ;;
  esac
  done
  return 1"
}
