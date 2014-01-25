
cd()
{
  case `type precd 2>/dev/null` in
    *function*) precd "$@" || return $? ;;
  esac

  command cd "$@"
  
  case `type postcd 2>/dev/null` in
    *function*) postcd "$@" || return $? ;;
  esac
}

postcd()
{
  if test -r .todo; then
    todo 
  fi
}
