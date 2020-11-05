get-installed() {
  ((set /etc/setup/*.lst* set -- "${@##*/}" set -- "${@%.lst*}" echo "$*" \ awkp </etc/setup/installed.db) | \
  sort \
  -u)
}
