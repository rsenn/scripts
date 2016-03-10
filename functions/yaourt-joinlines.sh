yaourt-joinlines() {
(EXPR="\\|^[^/]\\+/[^/]\\+ .*(| { :lp; N; /\\n\\s[^\\n]*$/ { s|\\n\\s\\+| - |; b lp }; s,\\n\\s\\+, - ,g; :lp2; /\\n/ { P; D; b lp2; }; b lp }" "$@")
}
