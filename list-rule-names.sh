#!/bin/sh

sed -n '/definition\s*(/ { 

  :lp1
  /{/! { 
    n
    b lp1
  }

  :lp2


  /^\s*}/ q

  /^\s*[a-z_]\+/! {
    n
    b lp2
  }

  :lp3

  s,//.*,,

  /;$/! {
    N
    b lp3
  }


  s,\s+, ,g
  s,^\s*,,
  s,\s*=.*,,

  p
  n
  b lp2
}' "$@"

