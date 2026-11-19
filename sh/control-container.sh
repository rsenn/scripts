#!/bin/bash
# Docker administration for the meshtastic work container: create it with USB
# serial passthrough, start it at system boot, run sshd (or runit/daemontools)
# inside it, find it again among dozens of containers, investigate it and
# troubleshoot it when docker misbehaves. Run on the docker host.
#
#   control-container.sh [-n] [-c CONTAINER] <command> [args]
#
# The "latest" container is the one you work in. It is remembered in
# $STATE_DIR/latest (set by create/migrate/mark), shown with a star in every
# listing, used as default target and protected against 'rm' and 'clean'.
#
# finding
#   find                 show the latest container; if none is marked, rank candidates
#   mark [CONTAINER]     remember CONTAINER (default: best candidate) as the latest
#   unmark               forget the mark (needed before 'rm' of that container)
#   list [-a]            containers, latest first and highlighted (-a: all, not just 12)
#   which                print only the name of the latest container (for scripts)
#
# investigating
#   investigate          checks: runs? exec works? IP, ports, sshd, USB/ttyACM*, init
#   status               short state, restart policy, init mode, services, devices
#   devices | usb        host and container view of ttyACM*/ttyUSB* and the device rules
#
# troubleshooting
#   fix-sshd             start sshd (docker exec, or namespaces if exec is broken)
#   forward [on|off|status] [PORT]   host port -> container sshd (socat), default $SSH_PORT
#   network [check|fix]  can the container reach the internet? checks route, forwarding,
#                        NAT/forward rules, DNS; 'fix' repairs what is missing (default: check)
#   usb-fix              create missing ttyACM*/ttyUSB* nodes inside the container
#   rescue [CMD...]      root shell/command through a surviving process (exec broken)
#   copy-out DIR [PATH]  docker cp PATH (default /home/coder) to DIR, works without exec
#   top | inspect | events | daemon-log | logs [ARGS]
#   clean                remove stopped auto-named leftovers (never the latest), asks first
#
# lifecycle
#   build [ARGS]         build $IMAGE from $DOCKERFILE (self-contained, empty context);
#                        ARGS go to docker build, e.g. --no-cache
#   update               build (NO_BUILD=1 skips it), then replace the latest container by a
#                        new one from $IMAGE under the same name: carries ssh host keys,
#                        tailscale state and password hashes over, mounts $HOME_SRC as the
#                        home, stops (never removes) the old one, then runs 'compare'
#   compare [OLD]        old container (default: the one 'update' replaced) against the latest:
#                        packages, users, sshd/sudo config, /usr/local/bin, docker settings
#   create [IMAGE]       create + start (restart policy, USB, ssh port, home), marks it latest
#   migrate              snapshot the latest container, start $NAME from the snapshot
#   rollback             undo 'update': stop the latest, start the replaced container again
#   start|stop|restart   lifecycle
#   shell [CMD...]       interactive shell (default: bash as $USER_IN, else sh)
#   autostart [on|off]   start with the docker daemon (and enable docker at boot)
#   init [MODE]          show/set init mode: ssh | runit | daemontools
#   install-init         (re)install the container-init entrypoint script
#   rm NAME...           remove containers; refuses the latest one, never defaults
#
# environment (defaults in brackets):
#   CONTAINER           target override (else the latest, else $NAME)
#   NAME [meshtastic-work]  name given to a new container   IMAGE [meshtastic-coding-work:alpine]
#   DOCKERFILE [~/Sources/meshtastic/alpine.Dockerfile]   what 'build' and 'update' build
#   BUILD_ARGS []       extra arguments for docker build in 'update' (--no-cache --pull)
#   HOME_SRC [/mnt/data/meshtastic-backup]   host dir mounted as /home/$USER_IN (empty = none)
#   SSH_PORT [22225]    host port -> container port 22 (empty = no publish)
#   INIT_MODE []        init mode for 'create' (empty: the image default, runit; old images: ssh)
#   RULES [c 166:* rmw, c 188:* rmw, c 189:* rmw]   ttyACM*, ttyUSB*, raw USB
#   NET_PROBE [1.1.1.1] address pinged by 'network'; NET_DNS_PROBE [github.com] name it resolves
#   EXTRA               extra arguments for 'docker create'   OLD [the latest]  USER_IN [coder]
#   STATE_DIR [~/.local/state/control-container]
#
# init modes (script /usr/local/bin/container-init, the container entrypoint; the image
# built from $DOCKERFILE ships it, older images get it installed by 'create'):
#   runit        PID 1 is runsvdir over /etc/service: sshd and tailscaled are services (default)
#   ssh          sshd and tailscaled start directly, then PID 1 runs a shell
#   daemontools  PID 1 is svscan over /etc/service (needs svscan in the image)
set -eu
shopt -s nullglob

NAME_SET=${NAME:+1}
NAME=${NAME:-meshtastic-work}
IMAGE_SET=${IMAGE:+1}
IMAGE=${IMAGE:-${SNAP:-meshtastic-coding-work:alpine}}
DOCKERFILE=${DOCKERFILE:-$HOME/Sources/meshtastic/alpine.Dockerfile}
HOME_SRC=${HOME_SRC-/mnt/data/meshtastic-backup}
SSH_PORT=${SSH_PORT:-22225}
INIT_MODE=${INIT_MODE:-}
BUILD_ARGS=${BUILD_ARGS:-}
RULES=${RULES:-c 166:* rmw, c 188:* rmw, c 189:* rmw}
EXTRA=${EXTRA:-}
USER_IN=${USER_IN:-coder}
INIT_PATH=/usr/local/bin/container-init
MODE_FILE=/etc/container-init.mode
STATE_DIR=${STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/control-container}
LATEST_FILE=$STATE_DIR/latest
PREV_FILE=$STATE_DIR/previous   # "<id> <name>" of the container the last 'update' replaced
FAMILY=${FAMILY:-meshtastic-coding-work}   # image family of the containers considered by find/clean

DRY=0
TARGET_OPT=${CONTAINER:-}
while :; do
  case ${1:-} in
    -n|--dry-run) DRY=1; shift ;;
    -c) [ $# -ge 2 ] || { echo "-c needs a container" >&2; exit 2; }; TARGET_OPT=$2; shift 2 ;;
    *) break ;;
  esac
done

if [ -t 1 ]; then B=$'\e[1m'; G=$'\e[1;32m'; R=$'\e[1;31m'; Y=$'\e[1;33m'; D=$'\e[2m'; Z=$'\e[0m'
else B=; G=; R=; Y=; D=; Z=; fi
STAR="${G}★${Z}"

die()  { echo "$0: $*" >&2; exit 1; }
run()  { echo "+ $*"; [ "$DRY" = 1 ] || "$@"; }
yes_() { printf '  %s✓%s %s\n' "$G" "$Z" "$*"; }
warn() { printf '  %s!%s %s\n' "$Y" "$Z" "$*"; WARNS=$((WARNS+1)); }
bad()  { printf '  %s✗%s %s\n' "$R" "$Z" "$*"; FAILS=$((FAILS+1)); }
note() { printf '    %s%s%s\n' "$D" "$*" "$Z"; }
head_() { printf '%s== %s%s\n' "$B" "$*" "$Z"; }
WARNS=0; FAILS=0

exists()  { docker inspect "$1" >/dev/null 2>&1; }
fullid()  { docker inspect -f '{{.Id}}' "$1" 2>/dev/null; }
cname()   { docker inspect -f '{{.Name}}' "$1" 2>/dev/null | sed 's|^/||'; }
running() { [ "$(docker inspect -f '{{.State.Running}}' "$1" 2>/dev/null)" = true ]; }

# --- the "latest" mark ---------------------------------------------------------
latest_id() {
  local id n
  [ -r "$LATEST_FILE" ] || return 1
  read -r id n <"$LATEST_FILE" || return 1
  fullid "$id" 2>/dev/null || return 1
}
is_latest() { local l; l=$(latest_id) || return 1; [ "$(fullid "$1")" = "$l" ]; }
set_mark() {
  [ "$DRY" = 1 ] && { echo "+ mark $1 as latest"; return; }
  mkdir -p "$STATE_DIR"; printf '%s %s\n' "$(fullid "$1")" "$(cname "$1")" >"$LATEST_FILE"
}

# resolve the target container into $C (full id) and $CN (name)
target() {
  local t
  if [ -n "$TARGET_OPT" ]; then t=$TARGET_OPT
  elif t=$(latest_id); then :
  elif exists "$NAME"; then t=$NAME
  else die "no latest container marked and no $NAME; run '$0 find' or '$0 create'"; fi
  exists "$t" || die "no container $t"
  C=$(fullid "$t"); CN=$(cname "$C")
}

fmt_name() { if is_latest "$1"; then printf '%s %s%s%s' "$STAR" "$G" "$(cname "$1")" "$Z"; else printf '  %s' "$(cname "$1")"; fi; }

# --- reaching a container even when docker exec is broken ----------------------
init_pid() { docker inspect -f '{{.State.Pid}}' "$C"; }
survivor_pid() {            # a live process of the container whose namespaces are readable
  local init pid f
  init=$(init_pid)
  for f in /sys/fs/cgroup/system.slice/docker-$C.scope/cgroup.procs /sys/fs/cgroup/docker/$C/cgroup.procs; do
    [ -r "$f" ] || continue
    for pid in $(cat "$f"); do
      [ "$pid" != "$init" ] || continue
      sudo -n readlink "/proc/$pid/ns/net" >/dev/null 2>&1 && { echo "$pid"; return 0; }
    done
  done
  return 1
}
EXEC=
exec_mode() {               # docker | nsenter | none
  [ -z "$EXEC" ] || return 0
  if running "$C" && timeout 8 docker exec "$C" true >/dev/null 2>&1; then EXEC=docker
  elif running "$C" && SURV=$(survivor_pid); then EXEC=nsenter
  else EXEC=none; fi
}
# cexec CMD...: as root inside the container, whichever way works.
# nsenter mode: no pid namespace (it is dead), private mount ns with a fresh /proc;
# pgrep/ps there show host processes.
cexec() {
  exec_mode
  case $EXEC in
    docker)  docker exec "$C" "$@" ;;
    nsenter) sudo -n nsenter -t "$SURV" -m -u -i -n unshare -m --propagation private \
               sh -c 'mount -t proc proc /proc 2>/dev/null; exec "$@"' sh "$@" ;;
    *) return 1 ;;
  esac
}

container_ip() {
  local ip
  ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$C" 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' || true)
  if [ -z "$ip" ]; then   # docker dropped the endpoint; ask the network namespace
    exec_mode
    [ "$EXEC" = none ] || ip=$(sudo -n nsenter -t "${SURV:-$(init_pid)}" -n ip -4 -o addr show scope global 2>/dev/null | awk '{sub(/\/.*/,"",$4); print $4; exit}')
  fi
  echo "$ip"
}
banner() { timeout 4 bash -c 'exec 3<>/dev/tcp/$0/$1 && head -n1 <&3' "$1" "$2" 2>/dev/null | tr -d '\r'; }
host_ports() { docker inspect -f '{{with index .HostConfig.PortBindings "22/tcp"}}{{(index . 0).HostPort}}{{end}}' "$C"; }

# --- the container entrypoint --------------------------------------------------
write_init() {
  cat >"$1" <<'INIT'
#!/bin/sh
# Container entrypoint, installed by control-container.sh.
# Mode: $INIT_MODE, else /etc/container-init.mode, else ssh.
#   ssh          start sshd (daemonizes)
#   runit        runsvdir over /etc/service, sshd as a supervised service
#   daemontools  svscan over /etc/service, sshd as a supervised service
mode=${INIT_MODE:-}
[ -n "$mode" ] || mode=$(cat /etc/container-init.mode 2>/dev/null) || mode=ssh
[ -n "$mode" ] || mode=ssh

ssh-keygen -A >/dev/null 2>&1
mkdir -p /run/sshd /var/run/sshd

# create /etc/service/sshd unless the image already ships a sshd service
svc_sshd() {
  d=/etc/service
  mkdir -p "$d" /etc/sv/sshd
  if [ ! -e "$d/sshd" ] && [ ! -e /service/sshd ]; then
    printf '#!/bin/sh\nmkdir -p /run/sshd\nexec /usr/sbin/sshd -D -e\n' >/etc/sv/sshd/run
    chmod +x /etc/sv/sshd/run
    ln -s /etc/sv/sshd "$d/sshd"
  fi
}

case $mode in
  runit)
    command -v runsvdir >/dev/null || { echo "container-init: runsvdir missing, falling back to ssh" >&2; mode=ssh; }
    ;;
  daemontools)
    command -v svscan >/dev/null || { echo "container-init: svscan missing, falling back to ssh" >&2; mode=ssh; }
    ;;
  ssh) ;;
  *) echo "container-init: unknown mode $mode, using ssh" >&2; mode=ssh ;;
esac

case $mode in
  runit)
    svc_sshd
    pgrep -x runsvdir >/dev/null || nohup runsvdir /etc/service >/var/log/runsvdir.log 2>&1 &
    ;;
  daemontools)
    svc_sshd
    pgrep -x svscan >/dev/null || nohup svscan /etc/service >/var/log/svscan.log 2>&1 &
    ;;
  *)
    pgrep -x sshd >/dev/null || /usr/sbin/sshd
    ;;
esac

# tailscale in userspace mode (no /dev/net/tun or CAP_NET_ADMIN here), proxy on localhost:1055
if [ -x /usr/sbin/tailscaled ] && ! pgrep -x tailscaled >/dev/null; then
  mkdir -p /var/lib/tailscale /var/run/tailscale
  nohup /usr/sbin/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 --state=/var/lib/tailscale/tailscaled.state >/var/log/tailscaled.log 2>&1 &
fi

# PID 1: interactive shell with a tty (docker run -it), else just stay alive
if [ -t 0 ]; then exec sh "$@"; fi
exec sleep infinity
INIT
  chmod +x "$1"
}

install_init() {
  local t; t=$(mktemp); write_init "$t"
  run docker cp "$t" "$CN:$INIT_PATH"
  rm -f "$t"
}
set_mode() {
  case $1 in ssh|runit|daemontools) ;; *) die "init mode must be ssh, runit or daemontools" ;; esac
  local t; t=$(mktemp); printf '%s\n' "$1" >"$t"
  run docker cp "$t" "$CN:$MODE_FILE"
  rm -f "$t"
}

# --- finding ---------------------------------------------------------------------
# candidates: containers of the work image family, running first, then newest start
candidates() {
  local id
  docker ps -a --format '{{.ID}}' | while read -r id; do
    docker inspect -f '{{.Config.Image}}|{{.State.Running}}|{{.State.StartedAt}}|{{.Id}}' "$id" |
      awk -F'|' -v fam="$FAMILY" 'index($1,fam){print $2"|"$3"|"$4}'
  done | sort -t'|' -k1,1r -k2,2r | cut -d'|' -f3
}
best_candidate() { candidates | head -n1; }

cmd_find() {
  local l c n=0
  if l=$(latest_id); then
    head_ "latest container"; show_one "$l" | table
  else
    echo "no container is marked as latest."
  fi
  head_ "candidates (image family '$FAMILY', running first, then newest start)"
  for c in $(candidates | head -n 8); do show_one "$c"; n=$((n+1)); done | table
  n=$(candidates | head -n 8 | wc -l)
  [ "$n" -gt 0 ] || echo "  (none)"
  if ! latest_id >/dev/null; then
    c=$(best_candidate || true)
    [ -z "$c" ] || echo "best guess: $(cname "$c"); remember it with: $0 mark $(cname "$c")"
  fi
}

# show_one ID: one tab separated row (mark, name, id, state, image, created, ports, restart)
show_one() {
  local id=$1 m=' '
  is_latest "$id" && m=1
  docker inspect -f '{{.Name}}|{{.State.Status}}|{{.Config.Image}}|{{.Created}}|{{range $p,$b := .HostConfig.PortBindings}}{{$p}}->{{(index $b 0).HostPort}} {{end}}|{{.HostConfig.RestartPolicy.Name}}' "$id" |
    awk -F'|' -v id="${id:0:12}" -v m="$m" 'BEGIN{OFS="\t"} {sub(/^\//,"",$1); sub(/ $/,"",$5); print m,$1,id,$2,$3,substr($4,1,16),($5==""?"-":$5),($6==""?"no":$6)}'
}

# table: tab separated rows on stdin -> aligned, coloured columns on a terminal
# (the latest container starred and green, running green, exited dim); plain tabs otherwise
table() {
  local -a rows=() c w=(0 0 0 0 0 0 0 0) hdr=("" NAME ID STATE IMAGE CREATED PORTS RESTART)
  local line i n out
  while IFS= read -r line; do rows+=("$line"); done
  [ "${#rows[@]}" -gt 0 ] || return 0
  if [ ! -t 1 ]; then printf '%s\n' "${rows[@]}"; return; fi
  for i in 1 2 3 4 5 6 7; do w[$i]=${#hdr[$i]}; done
  for line in "${rows[@]}"; do
    IFS=$'\t' read -ra c <<<"$line"
    for i in 1 2 3 4 5 6 7; do n=${#c[$i]}; [ "$n" -le "${w[$i]}" ] || w[$i]=$n; done
  done
  printf '%s  ' "$D"
  for i in 1 2 3 4 5 6 7; do printf '%-*s  ' "${w[$i]}" "${hdr[$i]}"; done
  printf '%s\n' "$Z"
  for line in "${rows[@]}"; do
    IFS=$'\t' read -ra c <<<"$line"
    if [ "${c[0]}" = 1 ]; then printf '%s ' "$STAR"; else printf '  '; fi
    out=$(printf '%-*s' "${w[1]}" "${c[1]}")
    if [ "${c[0]}" = 1 ]; then printf '%s%s%s  ' "$G" "$out" "$Z"; else printf '%s  ' "$out"; fi
    printf '%s%-*s%s  ' "$D" "${w[2]}" "${c[2]}" "$Z"
    out=$(printf '%-*s' "${w[3]}" "${c[3]}")
    case ${c[3]} in running) printf '%s%s%s  ' "$G" "$out" "$Z" ;; exited|created) printf '%s%s%s  ' "$D" "$out" "$Z" ;; *) printf '%s%s%s  ' "$Y" "$out" "$Z" ;; esac
    printf '%-*s  %-*s  %-*s  %s\n' "${w[4]}" "${c[4]}" "${w[5]}" "${c[5]}" "${w[6]}" "${c[6]}" "${c[7]}"
  done
}

cmd_list() {
  local all=0 id shown=0 total l
  [ "${1:-}" = -a ] && all=1
  total=$(docker ps -a -q | wc -l)
  l=$(latest_id || true)
  {
    [ -z "$l" ] || show_one "$l"
    for id in $(docker ps -a -q --no-trunc); do
      [ "$id" != "$l" ] || continue
      if [ "$all" = 0 ] && [ "$shown" -ge 12 ]; then break; fi
      show_one "$id"; shown=$((shown+1))
    done
  } | table
  [ "$all" = 1 ] || [ "$total" -le 13 ] || echo "${D}($total containers in all, 'list -a' shows every one)${Z}"
  [ -n "$l" ] || echo "${Y}no container is marked as latest: $0 find / $0 mark${Z}"
}

cmd_mark() {
  local t=${1:-}
  [ -n "$t" ] || t=$(best_candidate || true)
  [ -n "$t" ] || die "nothing to mark"
  exists "$t" || die "no container $t"
  set_mark "$t"
  echo "latest container is now: $(cname "$t") ($(echo "$(fullid "$t")" | cut -c1-12))"
}
cmd_unmark() { run rm -f "$LATEST_FILE"; echo "mark removed"; }

# --- investigating ---------------------------------------------------------------
cmd_status() {
  target
  echo "container: $(fmt_name "$C") ($(echo "$C" | cut -c1-12))"
  docker inspect -f 'state:   {{.State.Status}} (since {{.State.StartedAt}}){{"\n"}}image:   {{.Config.Image}}{{"\n"}}restart: {{.HostConfig.RestartPolicy.Name}}{{"\n"}}ports:   {{range $p,$b := .HostConfig.PortBindings}}{{$p}}->{{(index $b 0).HostPort}} {{end}}' "$C"
  echo "ip:      $(container_ip)"
  running "$C" || return 0
  exec_mode
  if [ "$EXEC" = none ]; then echo "exec:    ${R}unavailable${Z} (try: $0 investigate)"; return 0; fi
  [ "$EXEC" = docker ] || echo "exec:    ${Y}docker exec broken, using namespaces (host pid view)${Z}"
  cexec sh -c '
    echo "init:    $(cat '"$MODE_FILE"' 2>/dev/null || echo ssh)"
    for p in sshd runsvdir svscan tailscaled; do pgrep -x $p >/dev/null && echo "running: $p"; done
    command -v sv >/dev/null && pgrep -x runsvdir >/dev/null && sv status /etc/service/* 2>/dev/null | sed "s/^/service: /"
    ls /dev/ttyACM* /dev/ttyUSB* 2>/dev/null | sed "s/^/device:  /"; true'
}

cmd_devices() {
  local d maj min tty
  target
  head_ "host"
  tty=(/dev/ttyACM* /dev/ttyUSB*)
  if [ "${#tty[@]}" -gt 0 ]; then ls -l "${tty[@]}"; else echo "  no ttyACM*/ttyUSB* on the host"; fi
  head_ "docker config"
  echo "  cgroup rules: $(docker inspect -f '{{range .HostConfig.DeviceCgroupRules}}[{{.}}] {{end}}' "$C")"
  echo "  /dev bind:    $(docker inspect -f '{{range .Mounts}}{{if eq .Destination "/dev"}}{{.Source}}{{end}}{{end}}' "$C")"
  echo "  privileged:   $(docker inspect -f '{{.HostConfig.Privileged}}' "$C")"
  echo "  extra groups: $(docker inspect -f '{{range .HostConfig.GroupAdd}}{{.}} {{end}}' "$C")"
  head_ "container"
  running "$C" || { echo "  not running"; return; }
  exec_mode; [ "$EXEC" != none ] || { echo "  cannot enter the container (see: $0 investigate)"; return; }
  cexec sh -c 'ls -l /dev/ttyACM* /dev/ttyUSB* 2>&1 || true'
  head_ "host vs container (major:minor)"
  for d in /dev/ttyACM* /dev/ttyUSB*; do
    [ -e "$d" ] || continue
    maj=$(stat -c '%t:%T' "$d")
    min=$(cexec stat -c '%t:%T' "$d" 2>/dev/null || echo missing)
    if [ "$maj" = "$min" ]; then yes_ "node $d exists in the container ($maj)"; else bad "$d host $maj container $min  (try: $0 usb-fix)"; fi
  done
  head_ "access (not tested by opening: that would toggle DTR/RTS and reset the board)"
  if [ "$(docker inspect -f '{{.HostConfig.Privileged}}' "$C")" = true ] \
     || [ -n "$(docker inspect -f '{{range .HostConfig.Devices}}{{.PathOnHost}} {{end}}' "$C")" ] \
     || docker inspect -f '{{range .HostConfig.DeviceCgroupRules}}{{.}};{{end}}' "$C" | grep -q 'c 166:'; then
    yes_ "docker grants access to the device (rule, --device or privileged)"
  else
    bad "a node exists but docker grants no access: open() will fail with 'Operation not permitted'"
    note "a mknod'ed node does not help; the cgroup rule can only be set at creation"
    note "cure: recreate the container with '$0 create' (rule c 166:* rmw, /dev bind, dialout group)"
  fi
}

cmd_investigate() {
  local pid ip hp bn rules l tty d st
  target
  printf '%s=== investigating %s%s (%s)%s\n' "$B" "$Z" "$(fmt_name "$C")" "$(echo "$C" | cut -c1-12)" "$Z"
  is_latest "$C" || warn "this is NOT the container marked as latest ($(latest_id >/dev/null && cname "$(latest_id)" || echo none))"

  head_ "1. docker and container state"
  if docker info >/dev/null 2>&1; then yes_ "docker daemon answers"; else bad "docker daemon not reachable"; return 1; fi
  st=$(docker inspect -f '{{.State.Status}}' "$C")
  if [ "$st" = running ]; then yes_ "docker says: running (since $(docker inspect -f '{{.State.StartedAt}}' "$C" | cut -c1-19))"
  else bad "docker says: $st (exit $(docker inspect -f '{{.State.ExitCode}}' "$C")); start it: $0 start"; summary; return; fi
  pid=$(init_pid)
  if [ -d "/proc/$pid" ]; then yes_ "init process $pid alive ($(cat /proc/$pid/comm 2>/dev/null))"
  else bad "init process $pid is gone although docker says running"; fi
  if sudo -n readlink "/proc/$pid/ns/net" >/dev/null 2>&1; then yes_ "init process namespaces readable"
  else bad "init process $pid has lost its namespaces: PID 1 is dead, the pid namespace is orphaned"
       note "symptoms: docker exec fails with setns errors, restart hangs ('did not receive an exit event')"
       note "workarounds: $0 fix-sshd, $0 forward on, $0 rescue, $0 copy-out DIR; cure: restart the docker daemon"; fi
  EXEC=; exec_mode
  case $EXEC in
    docker)  yes_ "docker exec works" ;;
    nsenter) bad "docker exec is broken; reachable through process ${SURV} (namespace mode)" ;;
    none)    bad "cannot enter the container at all (docker exec broken and no usable process / sudo)" ;;
  esac
  yes_ "$(docker top "$C" 2>/dev/null | tail -n +2 | wc -l) processes in the container"
  l=$(docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' "$C")
  if [ "$l" = no ] || [ -z "$l" ]; then warn "restart policy 'no': not started at boot ($0 autostart on)"; else yes_ "restart policy: $l"; fi
  systemctl is-enabled docker >/dev/null 2>&1 && yes_ "docker service enabled at boot" || warn "docker service not enabled at boot"

  head_ "2. network"
  ip=$(container_ip)
  if [ -n "$ip" ]; then yes_ "container IP: $ip"; else bad "no container IP"; fi
  hp=$(host_ports)
  if [ -n "$hp" ]; then
    if docker inspect -f '{{json .NetworkSettings.Ports}}' "$C" | grep -q '"HostPort"'; then yes_ "docker publishes 22 -> host $hp"
    else warn "created with -p $hp:22 but docker has dropped the mapping ($0 forward on $hp)"; fi
    if ss -ltn 2>/dev/null | grep -q ":$hp "; then
      bn=$(banner 127.0.0.1 "$hp"); [ -n "$bn" ] && yes_ "host port $hp listens, banner: $bn" || warn "host port $hp listens but gives no ssh banner"
    else bad "nothing listens on host port $hp"; fi
  else note "no host port was published for 22"; fi

  if [ -n "$ip" ] && [ "$EXEC" != none ]; then
    sudo -n true 2>/dev/null && { cnet_ping "${NET_PROBE:-1.1.1.1}" && yes_ "container reaches the internet (${NET_PROBE:-1.1.1.1})" || bad "container has no internet ($0 network fix)"; }
  fi

  head_ "3. sshd"
  if [ -n "$ip" ]; then
    bn=$(banner "$ip" 22)
    if [ -n "$bn" ]; then yes_ "$ip:22 answers: $bn"; else bad "no ssh banner from $ip:22 ($0 fix-sshd)"; fi
  fi
  if [ "$EXEC" = docker ]; then
    cexec pgrep -x sshd >/dev/null 2>&1 && yes_ "sshd process inside" || warn "no sshd process inside"
    cexec test -x /usr/sbin/sshd && yes_ "/usr/sbin/sshd present" || bad "/usr/sbin/sshd missing"
    echo "    init mode: $(cexec cat $MODE_FILE 2>/dev/null || echo 'ssh (default)')"
  fi

  head_ "4. USB and ttyACM*"
  rules=$(docker inspect -f '{{range .HostConfig.DeviceCgroupRules}}{{.}};{{end}}' "$C")
  if echo "$rules" | grep -q 'c 166:'; then yes_ "cgroup rule for ttyACM* (major 166) present"
  elif [ "$(docker inspect -f '{{.HostConfig.Privileged}}' "$C")" = true ]; then warn "privileged container, no explicit rules"
  else bad "no device cgroup rule for major 166: ttyACM* will not work ($0 create sets it)"; fi
  echo "$rules" | grep -q 'c 189:' && yes_ "cgroup rule for raw USB (major 189) present" || warn "no rule for raw USB (major 189)"
  if docker inspect -f '{{range .Mounts}}{{.Destination}} {{end}}' "$C" | grep -qw /dev; then yes_ "/dev bind-mounted (hotplug nodes appear)"
  else warn "/dev not bind-mounted: nodes made at create time only"; fi
  tty=(/dev/ttyACM* /dev/ttyUSB*)
  [ "${#tty[@]}" -gt 0 ] && yes_ "host devices: ${tty[*]}" || warn "no ttyACM*/ttyUSB* on the host (board unplugged?)"
  if [ "$EXEC" != none ]; then
    for d in /dev/ttyACM* /dev/ttyUSB*; do
      [ -e "$d" ] || continue
      if cexec test -e "$d" 2>/dev/null; then yes_ "$d visible in the container"; else bad "$d missing in the container ($0 usb-fix)"; fi
    done
  fi
  summary
}
summary() {
  echo
  if [ "$FAILS" -gt 0 ]; then echo "${R}$FAILS failed${Z}, $WARNS warnings"; return 1
  elif [ "$WARNS" -gt 0 ]; then echo "${Y}$WARNS warnings${Z}, no failures"
  else echo "${G}all checks passed${Z}"; fi
}

# --- troubleshooting -------------------------------------------------------------
cmd_fix_sshd() {
  local ip bn
  target; running "$C" || die "$CN is not running ($0 start)"
  ip=$(container_ip); bn=$([ -n "$ip" ] && banner "$ip" 22 || true)
  if [ -n "$bn" ]; then echo "sshd already answers on $ip:22 ($bn)"; return 0; fi
  exec_mode; [ "$EXEC" != none ] || die "cannot enter the container (is passwordless sudo available?)"
  [ "$EXEC" = docker ] || echo "docker exec is broken, starting sshd through namespaces"
  run cexec sh -c 'mkdir -p /run/sshd; ssh-keygen -A >/dev/null 2>&1; /usr/sbin/sshd'
  [ "$DRY" = 1 ] && return 0
  sleep 1; bn=$([ -n "$ip" ] && banner "$ip" 22 || true)
  if [ -n "$bn" ]; then echo "sshd up: $bn   ssh $USER_IN@$ip"; else die "sshd did not come up; try: $0 rescue"; fi
}

FWD_PID=$STATE_DIR/forward.pid
cmd_forward() {
  local act=${1:-status} port=${2:-$SSH_PORT} ip pid sp=()
  target
  [ "$port" -lt 1024 ] 2>/dev/null && sp=(sudo -n)
  case $act in
    on)
      command -v socat >/dev/null || die "socat not installed"
      ss -ltn | grep -q ":$port " && die "host port $port is already in use ($0 forward off $port?)"
      ip=$(container_ip); [ -n "$ip" ] || die "no container IP"
      mkdir -p "$STATE_DIR"
      echo "+ socat TCP-LISTEN:$port,fork,reuseaddr TCP:$ip:22"
      [ "$DRY" = 1 ] && return 0
      "${sp[@]}" setsid socat "TCP-LISTEN:$port,fork,reuseaddr" "TCP:$ip:22" >/dev/null 2>&1 </dev/null &
      sleep 1
      pid=$(pgrep -f "^socat TCP-LISTEN:$port," | head -n1 || true)
      [ -n "$pid" ] || die "forwarder did not start"
      echo "$pid" >"$FWD_PID.$port"
      echo "forwarding host:$port -> $ip:22 (pid $pid; lost on reboot or docker restart)" ;;
    off)
      pid=$(pgrep -f "^socat TCP-LISTEN:$port," | head -n1 || true)
      [ -n "$pid" ] || { echo "no forwarder on $port"; return 0; }
      run sudo -n kill "$pid"; rm -f "$FWD_PID.$port" ;;
    status)
      pid=$(pgrep -f "^socat TCP-LISTEN:$port," | head -n1 || true)
      if [ -n "$pid" ]; then echo "forwarder on $port: pid $pid ($(ps -o args= -p "$pid"))"; else echo "no forwarder on $port"; fi ;;
    *) die "forward [on|off|status] [PORT]" ;;
  esac
}

# --- network ---------------------------------------------------------------------
# Symptom: the container reaches the host and the LAN gateway but not the internet.
# Causes seen: docker dropped the endpoint (default route gone), the docker firewall
# rules were flushed (no MASQUERADE, FORWARD policy drop), ip_forward off, bad resolv.conf.
# 'network fix' repairs these in place, without restarting docker or the container.
NET_PROBE=${NET_PROBE:-1.1.1.1}
NET_DNS_PROBE=${NET_DNS_PROBE:-github.com}
NET_TAG=control-container

net_pid() { exec_mode; if [ "$EXEC" = nsenter ]; then echo "$SURV"; else init_pid; fi; }
cnet() { sudo -n nsenter -t "$(net_pid)" -n "$@"; }       # run in the container's network namespace
cnet_ping() { cnet ping -c1 -W3 "$1" >/dev/null 2>&1; }

cmd_network() {
  local act=${1:-check} fix=0 net gw subnet br ip dev pingok dnsok n
  case $act in check|status) ;; fix) fix=1 ;; *) die "network [check|fix]" ;; esac
  target; running "$C" || die "$CN is not running"
  sudo -n true 2>/dev/null || die "needs passwordless sudo (nsenter, iptables)"
  FAILS=0; WARNS=0
  head_ "network of $(fmt_name "$C")"

  # which docker network, its gateway, subnet and bridge device
  net=$(docker inspect -f '{{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}' "$C" | awk '{print $1}')
  [ -n "$net" ] || net=$(docker inspect -f '{{.HostConfig.NetworkMode}}' "$C")
  [ "$net" != default ] || net=bridge
  gw=$(docker network inspect -f '{{range .IPAM.Config}}{{.Gateway}} {{end}}' "$net" 2>/dev/null | awk '{print $1}')
  subnet=$(docker network inspect -f '{{range .IPAM.Config}}{{.Subnet}} {{end}}' "$net" 2>/dev/null | awk '{print $1}')
  br=$(docker network inspect -f '{{index .Options "com.docker.network.bridge.name"}}' "$net" 2>/dev/null)
  [ -n "$br" ] || { [ "$net" = bridge ] && br=docker0 || br=br-$(docker network inspect -f '{{.Id}}' "$net" | cut -c1-12); }
  [ -n "$gw" ] && [ -n "$subnet" ] || die "cannot determine gateway/subnet of docker network '$net'"
  echo "    docker network $net: gateway $gw, subnet $subnet, bridge $br"

  # 1. address and default route inside the container
  ip=$(container_ip)
  if [ -n "$ip" ]; then yes_ "container address $ip"; else bad "container has no IPv4 address (docker network endpoint lost: recreate the container)"; summary; return 1; fi
  if cnet ip route 2>/dev/null | grep -q "^default via $gw "; then yes_ "default route via $gw"
  else
    bad "no default route via $gw in the container"
    if [ "$fix" = 1 ]; then run sudo -n nsenter -t "$(net_pid)" -n ip route replace default via "$gw" && yes_ "route restored"; fi
  fi

  # 2. host side: forwarding and bridge
  [ "$(cat /proc/sys/net/ipv4/ip_forward)" = 1 ] && yes_ "host ip_forward=1" || {
    bad "host ip_forward is 0"; [ "$fix" = 0 ] || run sudo -n sysctl -qw net.ipv4.ip_forward=1; }
  ip link show "$br" >/dev/null 2>&1 && yes_ "bridge $br exists" || bad "bridge $br missing on the host (docker network broken: restart docker)"
  cnet_ping "$gw" && yes_ "container reaches the gateway $gw" || bad "container cannot reach $gw (veth/bridge problem: restart docker)"

  # 3. internet by address
  if cnet_ping "$NET_PROBE"; then yes_ "container reaches $NET_PROBE"; pingok=1
  else
    pingok=0; bad "container cannot reach $NET_PROBE (the host can: $(ping -c1 -W2 "$NET_PROBE" >/dev/null 2>&1 && echo yes || echo no))"
    if sudo -n iptables -t nat -S POSTROUTING 2>/dev/null | grep -q -- "-s $subnet.*MASQUERADE"; then yes_ "NAT: MASQUERADE for $subnet present"
    else
      bad "NAT: no MASQUERADE for $subnet (docker's firewall rules are gone, flushed by ufw/nftables/tailscale?)"
      [ "$fix" = 0 ] || run sudo -n iptables -t nat -A POSTROUTING -s "$subnet" ! -o "$br" -m comment --comment "$NET_TAG" -j MASQUERADE
    fi
    if sudo -n iptables -S FORWARD 2>/dev/null | grep -q -E -- "-i $br .*-j ACCEPT|DOCKER-FORWARD"; then yes_ "FORWARD: traffic from $br accepted"
    else
      bad "FORWARD: policy $(sudo -n iptables -S FORWARD | awk '/^-P/{print $3}') and nothing accepts $br"
      if [ "$fix" = 1 ]; then
        run sudo -n iptables -I FORWARD -i "$br" -m comment --comment "$NET_TAG" -j ACCEPT
        run sudo -n iptables -I FORWARD -o "$br" -m conntrack --ctstate RELATED,ESTABLISHED -m comment --comment "$NET_TAG" -j ACCEPT
      fi
    fi
    if [ "$fix" = 1 ] && [ "$DRY" = 0 ]; then
      sleep 1; if cnet_ping "$NET_PROBE"; then yes_ "now reaches $NET_PROBE"; pingok=1; FAILS=$((FAILS-1)); else bad "still no route to $NET_PROBE; try '$0 investigate' or restart the docker daemon"; fi
    fi
  fi

  # 4. DNS
  if [ "$pingok" = 1 ] && [ "$DRY" = 0 ] || [ "$fix" = 0 ]; then
    exec_mode
    if [ "$EXEC" = none ]; then warn "cannot enter the container to test DNS"
    else
      echo "    resolv.conf: $(cexec grep -E '^(nameserver|search)' /etc/resolv.conf 2>/dev/null | tr '\n' ' ')"
      if cexec getent hosts "$NET_DNS_PROBE" >/dev/null 2>&1; then yes_ "DNS resolves $NET_DNS_PROBE"; dnsok=1
      else
        dnsok=0; bad "DNS cannot resolve $NET_DNS_PROBE"
        if [ "$fix" = 1 ] && [ "$pingok" = 1 ]; then
          # upstream resolvers of the host (not the 127.0.0.53 stub), then public ones
          n=$(grep -h '^nameserver' /run/systemd/resolve/resolv.conf 2>/dev/null | grep -v '127\.' | head -n2; echo "nameserver 1.1.1.1")
          echo "    writing resolv.conf: $(echo "$n" | tr '\n' ' ')"
          [ "$DRY" = 1 ] || { echo "$n" | cexec sh -c 'cat >/etc/resolv.conf'; cexec getent hosts "$NET_DNS_PROBE" >/dev/null 2>&1 && { yes_ "DNS works now"; FAILS=$((FAILS-1)); }; }
        fi
      fi
    fi
  fi
  [ "$fix" = 1 ] || [ "$FAILS" = 0 ] || echo "    repair with: $0 network fix"
  [ "$fix" = 0 ] || echo "    rules added carry the comment '$NET_TAG'; docker restores its own rules on 'systemctl restart docker' (stops containers)"
  summary
}

cmd_usb_fix() {
  local d spec n=0 t
  target; running "$C" || die "$CN is not running"
  exec_mode; [ "$EXEC" != none ] || die "cannot enter the container"
  for d in /dev/ttyACM* /dev/ttyUSB*; do
    [ -e "$d" ] || continue
    cexec test -e "$d" 2>/dev/null && continue
    spec=$(printf '%d %d' "0x$(stat -c %t "$d")" "0x$(stat -c %T "$d")")
    # shellcheck disable=SC2086
    run cexec sh -c "mknod $d c $spec && chmod 660 $d && chgrp dialout $d 2>/dev/null; true" && n=$((n+1))
  done
  [ "$DRY" = 1 ] && return 0
  echo "$n node(s) created. A node alone does not grant access: without a cgroup rule (c 166:* rmw) open() still fails."
  echo "check with '$0 devices'; the rule can only be set at creation ('$0 create')."
}

cmd_rescue() {
  target; running "$C" || die "$CN is not running"
  exec_mode
  [ "$EXEC" != none ] || die "no way in: need a live process in the container and passwordless sudo"
  [ "$EXEC" = nsenter ] && echo "${Y}root shell through namespaces; ps shows host processes${Z}" >&2
  if [ $# -gt 0 ]; then cexec "$@"; return; fi
  if [ "$EXEC" = docker ]; then docker exec -it "$C" sh
  else sudo -n nsenter -t "$SURV" -m -u -i -n unshare -m --propagation private sh -c 'mount -t proc proc /proc 2>/dev/null; exec sh'; fi
}

cmd_copy_out() {
  local dst=${1:-} src=${2:-/home/coder}
  [ -n "$dst" ] || die "copy-out DIR [PATH]"
  target
  mkdir -p "$dst"
  run docker cp "$C:$src" "$dst"
  [ "$DRY" = 1 ] || echo "copied $src to $dst ($(du -sh "$dst" | cut -f1))"
}

cmd_top()        { target; docker top "$C"; }
cmd_inspect()    { target; docker inspect "$C" | sed -n '1,400p'; }
cmd_events()     { target; docker events --filter "container=$C" --since "${1:-1h}" --until 0s 2>/dev/null || docker events --filter "container=$C" --since 1h --until "$(date +%s)"; }
cmd_daemon_log() { target; journalctl -u docker --no-pager --since "${1:-2 hours ago}" | grep -E "$(echo "$C" | cut -c1-12)|setns|exit event|runc" | tail -n 40; }

cmd_clean() {
  local id l n=0 junk=() a
  l=$(latest_id || true)
  for id in $(docker ps -a -q --no-trunc --filter status=exited --filter status=created); do
    [ "$id" != "$l" ] || continue
    docker inspect -f '{{.Name}}' "$id" | sed 's|^/||' | grep -qE '^[a-z]+_[a-z]+$' || continue
    docker inspect -f '{{.Config.Image}}' "$id" | grep -q "$FAMILY" || continue
    junk+=("$id")
  done
  [ "${#junk[@]}" -gt 0 ] || { echo "nothing to clean"; return; }
  for id in "${junk[@]}"; do echo "  $(cname "$id")  $(docker inspect -f '{{.State.Status}} {{.Created}}' "$id" | cut -c1-34)"; n=$((n+1)); done
  echo "latest: ${l:+$(cname "$l")} (kept)"
  printf 'remove these %d stopped, auto-named containers? [y/N] ' "$n"; read -r a
  [ "$a" = y ] || die "aborted"
  run docker rm "${junk[@]}"
}

# --- lifecycle -------------------------------------------------------------------
cmd_create() {
  local args rl r g
  [ -z "${1:-}" ] || IMAGE=$1
  exists "$NAME" && die "container $NAME already exists (choose NAME=..., or rm it)"
  docker image inspect "$IMAGE" >/dev/null 2>&1 || die "no image $IMAGE"
  args=(--name "$NAME" -it --init --restart unless-stopped
        --label control-container=1
        --entrypoint "$INIT_PATH"
        -e "INIT_MODE=")
  IFS=, read -ra rl <<<"$RULES"
  for r in "${rl[@]}"; do r=${r# }; args+=(--device-cgroup-rule="$r"); done
  args+=(-v /dev:/dev)
  g=$(getent group dialout | cut -d: -f3 || true)
  [ -z "$g" ] || args+=(--group-add "$g")
  [ -z "$SSH_PORT" ] || args+=(-p "$SSH_PORT":22)
  [ -z "$HOME_SRC" ] || [ ! -d "$HOME_SRC" ] || args+=(-v "$HOME_SRC:/home/$USER_IN")
  # shellcheck disable=SC2206
  args+=($EXTRA)
  run docker create "${args[@]}" "$IMAGE"
  CN=$NAME
  if image_has_init; then
    [ -z "$INIT_MODE" ] || set_mode "$INIT_MODE"       # else the image's own default (runit)
  elif [ "$DRY" = 0 ]; then install_init; set_mode "${INIT_MODE:-ssh}"
  else echo "+ (install $INIT_PATH, mode ${INIT_MODE:-ssh})"; fi
  [ -z "${CARRY_FROM:-}" ] || carry_state "$CARRY_FROM" "$NAME"
  run docker start "$NAME"
  [ "$DRY" = 1 ] || { C=$(fullid "$NAME"); set_mark "$NAME"; sleep 2; cmd_status; }
  echo "marked $NAME as latest; ssh -p ${SSH_PORT:-22} $USER_IN@<host>"
}

# image_has_init: does $IMAGE ship /usr/local/bin/container-init (label set by the Dockerfile)?
image_has_init() {
  [ "$(docker image inspect -f '{{index .Config.Labels "control-container.init"}}' "$IMAGE" 2>/dev/null)" = 1 ]
}

# cfile CONTAINER PATH: contents of one file through docker cp, which works in stopped
# containers and when docker exec is broken
cfile() { docker cp "$1:$2" - 2>/dev/null | tar -xO 2>/dev/null || true; }

# ctar CONTAINER PATH: names inside a directory, one per line, sorted
ctar() { docker cp "$1:$2" - 2>/dev/null | tar -t 2>/dev/null | sed 's|^[^/]*/||; /^$/d' | sort || true; }

# carry_state OLD NEW: copy what must survive a rebuild from OLD into the created, not yet
# started NEW: ssh host keys (clients keep trusting the host) and tailscale state (stays
# logged in). tar streams keep owner and mode.
carry_state() {
  local old=$1 new=$2 k n=0
  echo "carrying state from $(cname "$old")"
  for k in ssh_host_rsa_key ssh_host_rsa_key.pub ssh_host_ed25519_key ssh_host_ed25519_key.pub \
           ssh_host_ecdsa_key ssh_host_ecdsa_key.pub; do
    [ -n "$(cfile "$old" "/etc/ssh/$k" | head -c1)" ] || continue
    if [ "$DRY" = 1 ]; then echo "+ carry /etc/ssh/$k"; continue; fi
    docker cp "$old:/etc/ssh/$k" - | docker cp - "$new:/etc/ssh/" && n=$((n+1))
  done
  echo "    $n ssh host key file(s)"
  if [ -n "$(ctar "$old" /var/lib/tailscale)" ]; then
    if [ "$DRY" = 1 ]; then echo "+ carry /var/lib/tailscale"
    else docker cp "$old:/var/lib/tailscale" - | docker cp - "$new:/var/lib/" && echo "    tailscale state"; fi
  else echo "    no tailscale state in the old container (log in with: tailscale up)"; fi
}

# carry_passwords OLD NEW: password hashes of the login users from the old shadow file into
# the running NEW; never written to a file, never printed. The image keeps them locked.
carry_passwords() {
  local old=$1 new=$2 n filter='($1=="coder"||$1=="roman") && $2!~/^[!*]/ && $2!="" {print $1":"$2}'
  n=$(cfile "$old" /etc/shadow | awk -F: "$filter" | wc -l)
  [ "$n" -gt 0 ] || { echo "    no password hashes to carry"; return 0; }
  if [ "$DRY" = 1 ]; then echo "+ carry $n password hash(es)"; return 0; fi
  cfile "$old" /etc/shadow | awk -F: "$filter" | docker exec -i "$new" chpasswd -e && echo "    $n password hash(es)"
}

# --- build, update, compare --------------------------------------------------------
# The Dockerfile is self-contained: it is fed on stdin with an empty build context
# (the firmware checkout would be sent to the daemon otherwise).
cmd_build() {
  local ctx
  [ -r "$DOCKERFILE" ] || die "no Dockerfile $DOCKERFILE (set DOCKERFILE=...)"
  ctx=$(mktemp -d)
  echo "+ docker build -f - -t $IMAGE $* <$DOCKERFILE   (empty context)"
  if [ "$DRY" = 1 ]; then rmdir "$ctx"; return 0; fi
  docker build -f - -t "$IMAGE" "$@" "$ctx" <"$DOCKERFILE" || { rmdir "$ctx"; die "build failed"; }
  rmdir "$ctx"
}

# update_restore OLD OLDNAME: the update failed after the old container was stopped
update_restore() {
  local old=$1 oldname=$2
  echo "update failed, going back to $oldname" >&2
  if exists "$NAME" && [ "$(fullid "$NAME")" != "$(fullid "$old")" ]; then
    docker rename "$NAME" "$NAME-failed-$(date +%Y%m%d-%H%M%S)" || true
  fi
  [ "$(cname "$old")" = "$oldname" ] || docker rename "$old" "$oldname" || true
  docker update --restart unless-stopped "$old" >/dev/null || true
  docker start "$old" >/dev/null && { docker exec -d "$old" /usr/sbin/sshd 2>/dev/null || true; }
  set_mark "$old"
}

cmd_update() {
  local old oldname stamp
  target; old=$C; oldname=$CN
  [ -r "$DOCKERFILE" ] || die "no Dockerfile $DOCKERFILE (set DOCKERFILE=...)"
  if [ -n "$HOME_SRC" ]; then
    [ -d "$HOME_SRC" ] || die "HOME_SRC $HOME_SRC does not exist; /home/$USER_IN of the old container is lost with it ($0 copy-out DIR first)"
    [ -n "$(ls -A "$HOME_SRC" 2>/dev/null)" ] || die "HOME_SRC $HOME_SRC is empty"
  fi
  [ -n "$NAME_SET" ] || NAME=$oldname
  echo "replacing $oldname ($(echo "$old" | cut -c1-12)) by $NAME from image $IMAGE; home ${HOME_SRC:-none}, ssh port ${SSH_PORT:-none}"

  head_ "1. image"
  # shellcheck disable=SC2086
  if [ "${NO_BUILD:-0}" = 1 ]; then echo "NO_BUILD=1: using the existing image $IMAGE"; else cmd_build $BUILD_ARGS; fi
  if [ "$DRY" = 0 ]; then
    docker image inspect "$IMAGE" >/dev/null 2>&1 || die "no image $IMAGE"
    image_has_init || die "image $IMAGE has no container-init (not built from $DOCKERFILE?)"
  fi

  head_ "2. stop the old container (kept, not removed)"
  if running "$old"; then
    run timeout 90 docker stop -t 10 "$old" || {
      echo "docker stop failed or timed out, killing" >&2
      run timeout 30 docker kill "$old" || die "cannot stop $oldname: docker is wedged ('sudo systemctl restart docker' stops all containers, then rerun)"; }
  fi
  run docker update --restart=no "$old"
  stamp=$(date +%Y%m%d-%H%M%S)
  [ "$NAME" != "$oldname" ] || run docker rename "$old" "$oldname-old-$stamp"
  if [ -n "$SSH_PORT" ] && ss -ltn | grep -q ":$SSH_PORT "; then
    echo "host port $SSH_PORT is busy (a '$0 forward' leftover?), trying to free it"
    cmd_forward off "$SSH_PORT" || true; sleep 1
    if ss -ltn | grep -q ":$SSH_PORT "; then
      [ "$DRY" = 1 ] || { update_restore "$old" "$oldname"; die "host port $SSH_PORT is still busy"; }
    fi
  fi

  head_ "3. create and start the new container"
  if [ "$DRY" = 1 ]; then
    echo "+ create $NAME from $IMAGE (home $HOME_SRC, port $SSH_PORT, device rules, /dev bind)"
    echo "+ carry ssh host keys, tailscale state, password hashes from $oldname; compare; investigate"
    return 0
  fi
  if ! CARRY_FROM=$old cmd_create; then update_restore "$old" "$oldname"; exit 1; fi
  printf '%s %s\n' "$old" "$oldname" >"$PREV_FILE"
  C=$(fullid "$NAME"); CN=$NAME
  carry_passwords "$old" "$NAME" || echo "    password hashes not carried" >&2

  head_ "4. does the new container match the old one?"
  cmd_compare "$old" || true
  head_ "5. does it work?"
  cmd_investigate || true
  echo
  echo "old container: $(cname "$old") (stopped, restart policy off); '$0 rollback' brings it back, '$0 rm $(cname "$old")' removes it"
}

# cmp_sets LABEL OLDLIST NEWLIST: lines only in the old list are failures (lost), lines only
# in the new list are listed as additions
cmp_sets() {
  local label=$1 lost added n
  lost=$(comm -23 "$2" "$3"); added=$(comm -13 "$2" "$3")
  n=$(wc -l <"$2")
  if [ -z "$lost" ]; then yes_ "$label: all $n of the old container present"
  else bad "$label: missing in the new container:"; echo "$lost" | sed 's/^/        /'; fi
  [ -z "$added" ] || note "$label: $(echo "$added" | wc -l) added in the new one: $(echo "$added" | head -n 12 | tr '\n' ' ')"
}

cmd_compare() {
  local old=${1:-${OLD:-}} new T k o nw
  if [ -z "$old" ] && [ -r "$PREV_FILE" ]; then read -r old _ <"$PREV_FILE" || true; fi
  [ -n "$old" ] || die "compare OLD-CONTAINER (or run '$0 update' first)"
  exists "$old" || die "no container $old"
  target; new=$C
  [ "$(fullid "$old")" != "$new" ] || die "$old is the latest container itself; give the old one"
  old=$(fullid "$old")
  T=$(mktemp -d); FAILS=0; WARNS=0
  head_ "old $(cname "$old") ($(echo "$old" | cut -c1-12)) against new $(cname "$new") ($(echo "$new" | cut -c1-12))"
  note "files are read with docker cp; nothing needs a working docker exec"

  echo "${B}packages${Z}"
  cfile "$old" /etc/apk/world | sort -u >"$T/o"; cfile "$new" /etc/apk/world | sort -u >"$T/n"
  [ -s "$T/o" ] || warn "no /etc/apk/world in the old container"
  cmp_sets "requested (apk world)" "$T/o" "$T/n"
  cfile "$old" /lib/apk/db/installed | awk '/^P:/{print substr($0,3)}' | sort -u >"$T/o"
  cfile "$new" /lib/apk/db/installed | awk '/^P:/{print substr($0,3)}' | sort -u >"$T/n"
  cmp_sets "installed packages" "$T/o" "$T/n"

  echo "${B}users and groups${Z}"
  cfile "$old" /etc/passwd | awk -F: 'NF>5{print $1":"$3":"$4":"$6":"$7}' | sort -u >"$T/o"
  cfile "$new" /etc/passwd | awk -F: 'NF>5{print $1":"$3":"$4":"$6":"$7}' | sort -u >"$T/n"
  cmp_sets "passwd (name:uid:gid:home:shell)" "$T/o" "$T/n"
  cfile "$old" /etc/group | awk -F: 'NF>2{print $1":"$3}' | sort -u >"$T/o"
  cfile "$new" /etc/group | awk -F: 'NF>2{print $1":"$3}' | sort -u >"$T/n"
  cmp_sets "groups (name:gid)" "$T/o" "$T/n"
  cfile "$old" /etc/group >"$T/go"; cfile "$new" /etc/group >"$T/gn"
  k=$(awk -F: 'NR==FNR{m[$1]=","$4","; next} $4!="" {n=split($4,a,","); for(i=1;i<=n;i++) if (index(m[$1], ","a[i]",")==0) print $1": "a[i]}' "$T/gn" "$T/go")
  if [ -z "$k" ]; then yes_ "group members: every old member is still in its group"
  else bad "group members missing in the new container:"; echo "$k" | sed 's/^/        /'; fi
  k=$(cfile "$old" /etc/shadow | awk -F: '($1=="coder"||$1=="roman") && $2!~/^[!*]/ && $2!=""{print $1}' | sort -u | tr '\n' ' ')
  nw=$(cfile "$new" /etc/shadow | awk -F: '($1=="coder"||$1=="roman") && $2!~/^[!*]/ && $2!=""{print $1}' | sort -u | tr '\n' ' ')
  if [ "$k" = "$nw" ]; then yes_ "password set for: ${k:-nobody}"; else warn "login passwords: old [$k] new [$nw] ($0 update carries them)"; fi

  echo "${B}configuration${Z}"
  eff() { grep -v '^[[:space:]]*#' | sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//' | grep . | sort -u || true; }
  cfile "$old" /etc/ssh/sshd_config | eff >"$T/o"; cfile "$new" /etc/ssh/sshd_config | eff >"$T/n"
  cmp_sets "sshd_config (active lines)" "$T/o" "$T/n"
  { cfile "$old" /etc/sudoers; cfile "$old" /etc/sudoers.d; } | eff >"$T/o"
  { cfile "$new" /etc/sudoers; cfile "$new" /etc/sudoers.d; } | eff >"$T/n"
  cmp_sets "sudoers (active lines)" "$T/o" "$T/n"
  cfile "$old" /etc/shells | eff >"$T/o"; cfile "$new" /etc/shells | eff >"$T/n"
  cmp_sets "/etc/shells" "$T/o" "$T/n"
  ctar "$old" /usr/local/bin >"$T/o"; ctar "$new" /usr/local/bin >"$T/n"
  cmp_sets "/usr/local/bin" "$T/o" "$T/n"
  ctar "$old" /etc/udev/rules.d >"$T/o"; ctar "$new" /etc/udev/rules.d >"$T/n"
  cmp_sets "/etc/udev/rules.d" "$T/o" "$T/n"
  for k in /etc/udev/rules.d/99-platformio-udev.rules /etc/rsyncd.conf /etc/man_db.conf; do
    o=$(cfile "$old" "$k" | sha256sum | cut -c1-16); nw=$(cfile "$new" "$k" | sha256sum | cut -c1-16)
    if [ "$o" = "$nw" ]; then yes_ "$k identical"; else warn "$k differs"; fi
  done
  for k in glow yazi ya; do
    o=$(docker cp "$old:/usr/local/bin/$k" - 2>/dev/null | tar -xO 2>/dev/null | sha256sum | cut -c1-12)
    nw=$(docker cp "$new:/usr/local/bin/$k" - 2>/dev/null | tar -xO 2>/dev/null | sha256sum | cut -c1-12)
    if [ "$o" = "$nw" ]; then yes_ "/usr/local/bin/$k identical"; else note "/usr/local/bin/$k differs (other build or version: fine if it is the pinned one)"; fi
  done
  for k in rsa ed25519 ecdsa; do
    o=$(cfile "$old" /etc/ssh/ssh_host_${k}_key.pub | cut -d' ' -f1,2); nw=$(cfile "$new" /etc/ssh/ssh_host_${k}_key.pub | cut -d' ' -f1,2)
    [ -n "$o" ] || continue
    if [ "$o" = "$nw" ]; then yes_ "ssh host key $k carried over"; else warn "ssh host key $k differs: clients will see a changed host key"; fi
  done

  echo "${B}docker settings${Z} (old / new)"
  for k in 'restart:{{.HostConfig.RestartPolicy.Name}}' \
           'ports:{{range $p,$b := .HostConfig.PortBindings}}{{$p}}->{{(index $b 0).HostPort}} {{end}}' \
           'cgroup rules:{{range .HostConfig.DeviceCgroupRules}}[{{.}}] {{end}}' \
           'binds:{{range .Mounts}}{{.Source}}:{{.Destination}} {{end}}' \
           'groups:{{range .HostConfig.GroupAdd}}{{.}} {{end}}' \
           'entrypoint:{{range .Config.Entrypoint}}{{.}} {{end}}'; do
    o=$(docker inspect -f "${k#*:}" "$old" 2>/dev/null); nw=$(docker inspect -f "${k#*:}" "$new" 2>/dev/null)
    if [ "$o" = "$nw" ]; then yes_ "${k%%:*}: ${o:-(none)}"
    elif [ -n "$o" ] && [ -z "$nw" ]; then warn "${k%%:*}: old [$o], new has none"
    else note "${k%%:*}: [${o:-none}] / [${nw:-none}]"; fi
  done
  rm -rf "$T"
  summary || true
  FAILS=0; WARNS=0
}

cmd_migrate() {
  local OLD used_kb free_kb
  [ -n "$IMAGE_SET" ] || IMAGE=${SNAP:-meshtastic-coding-work:usb-pre2}   # the snapshot, not the built image
  HOME_SRC=                                                              # the snapshot contains the home
  OLD=${OLD:-$(latest_id || true)}
  [ -n "$OLD" ] || die "no latest container; set OLD=..."
  exists "$OLD" || die "no container $OLD"
  exists "$NAME" && die "container $NAME already exists; rm it or set NAME=..."
  docker image inspect "$IMAGE" >/dev/null 2>&1 && die "image $IMAGE already exists; remove it or set IMAGE=..."
  running "$OLD" || die "$(cname "$OLD") is not running"
  C=$OLD; exec_mode
  [ "$EXEC" = docker ] || die "docker exec into $(cname "$OLD") is broken: use '$0 copy-out DIR' and restart docker instead"

  used_kb=$(docker exec "$OLD" du -sk /home/coder 2>/dev/null | cut -f1 || echo 0)
  free_kb=$(df -Pk "$(docker info -f '{{.DockerRootDir}}')" | awk 'NR==2{print $4}')
  echo "container /home/coder: $((used_kb / 1024)) MB, free on docker root: $((free_kb / 1024)) MB"
  [ "$free_kb" -ge $((used_kb * 2 + 2097152)) ] || die "not enough free space for a snapshot (need about 2x /home/coder + 2 GB)"

  run docker commit -m "snapshot before migrate" --change "ENTRYPOINT [\"$INIT_PATH\"]" "$OLD" "$IMAGE"
  run docker stop "$OLD"
  if ! cmd_create; then
    echo "start failed, going back to $(cname "$OLD")" >&2
    run docker start "$OLD"; run docker exec -d "$OLD" /usr/sbin/sshd
    exit 1
  fi
  echo "previous container $(cname "$OLD") is stopped, not removed; '$0 rollback' restores it"
}

cmd_rollback() {
  local old=${OLD:-} oldname="" cur stamp
  if [ -z "$old" ] && [ -r "$PREV_FILE" ]; then read -r old oldname <"$PREV_FILE" || true; fi
  [ -n "$old" ] || die "rollback needs OLD=<previous container> (or an earlier '$0 update')"
  exists "$old" || die "no container $old"
  oldname=${oldname:-$(cname "$old")}
  cur=$(latest_id || true)
  [ -n "$cur" ] || { exists "$NAME" && cur=$(fullid "$NAME") || true; }
  stamp=$(date +%Y%m%d-%H%M%S)
  if [ -n "$cur" ] && [ "$cur" != "$(fullid "$old")" ]; then
    run docker update --restart=no "$cur"
    run timeout 90 docker stop -t 10 "$cur" || run timeout 30 docker kill "$cur" || die "cannot stop $(cname "$cur")"
    [ "$(cname "$cur")" != "$oldname" ] || run docker rename "$cur" "$oldname-rolledback-$stamp"
  fi
  [ "$(cname "$old")" = "$oldname" ] || run docker rename "$old" "$oldname"
  run docker update --restart unless-stopped "$old"
  run docker start "$old"
  [ "$DRY" = 1 ] || { docker exec -d "$old" /usr/sbin/sshd 2>/dev/null || true; set_mark "$old"; }
  echo "rolled back to $oldname, marked latest; sshd restarted (tmux, claude and other sessions must be started again)"
}

cmd_autostart() {
  target
  case ${1:-} in
    on)  run docker update --restart unless-stopped "$C"
         systemctl is-enabled docker >/dev/null 2>&1 || run sudo systemctl enable docker ;;
    off) run docker update --restart no "$C" ;;
    *)   echo "restart policy: $(docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' "$C")"
         echo "docker enabled: $(systemctl is-enabled docker 2>&1 || true)" ;;
  esac
}

cmd_init() {
  target
  if [ -z "${1:-}" ]; then docker exec "$C" cat "$MODE_FILE" 2>/dev/null || echo "ssh (default)"; return; fi
  set_mode "$1"
  echo "mode set to $1; takes effect on the next '$0 restart'"
}

cmd_shell() {
  target; running "$C" || run docker start "$C"
  exec_mode
  if [ "$EXEC" != docker ]; then echo "docker exec is broken ($0 investigate); use '$0 rescue' or ssh" >&2; exit 1; fi
  if [ $# -gt 0 ]; then docker exec -it "$C" "$@"; return; fi
  docker exec -it -u "$USER_IN" -w "/home/$USER_IN" "$C" bash -l 2>/dev/null || docker exec -it "$C" sh
}

cmd_rm() {
  local t id a
  [ $# -gt 0 ] || die "rm needs explicit container names (it never defaults)"
  for t in "$@"; do
    exists "$t" || die "no container $t"
    id=$(fullid "$t")
    if is_latest "$id"; then die "refusing: $(cname "$id") is marked as the latest container ($0 unmark first, then rm)"; fi
  done
  printf 'remove %s? Its filesystem is lost unless committed or copied out. [y/N] ' "$*"
  read -r a; [ "$a" = y ] || die "aborted"
  run docker rm -f "$@"
}

need_target() { target; }
case ${1:-} in
  find)         cmd_find ;;
  mark)         shift; cmd_mark "$@" ;;
  unmark)       cmd_unmark ;;
  list|ls)      shift; cmd_list "$@" ;;
  which)        target; echo "$CN" ;;
  investigate|inv|doctor) cmd_investigate ;;
  status)       cmd_status ;;
  devices|usb)  cmd_devices ;;
  fix-sshd)     cmd_fix_sshd ;;
  forward)      shift; cmd_forward "$@" ;;
  network|net)  shift; cmd_network "$@" ;;
  usb-fix)      cmd_usb_fix ;;
  rescue)       shift; cmd_rescue "$@" ;;
  copy-out)     shift; cmd_copy_out "$@" ;;
  top)          cmd_top ;;
  inspect)      cmd_inspect ;;
  events)       shift; cmd_events "$@" ;;
  daemon-log)   shift; cmd_daemon_log "$@" ;;
  logs)         shift; target; docker logs -f "$@" "$C" ;;
  clean)        cmd_clean ;;
  create)       shift; cmd_create "$@" ;;
  build)        shift; cmd_build "$@" ;;
  update)       cmd_update ;;
  compare|diff) shift; cmd_compare "$@" ;;
  migrate)      cmd_migrate ;;
  rollback|--rollback) cmd_rollback ;;
  start)        target; run docker start "$C" ;;
  stop)         target; run docker stop "$C" ;;
  restart)      target; run docker restart "$C" ;;
  shell|sh)     shift; cmd_shell "$@" ;;
  autostart)    shift; cmd_autostart "$@" ;;
  init)         shift; cmd_init "$@" ;;
  install-init) target; CN=$CN; install_init; echo "installed; takes effect on the next restart" ;;
  rm)           shift; cmd_rm "$@" ;;
  ""|-h|--help|help) sed -n '2,/^set -eu/p' "$0" | sed '$d;s/^# \{0,1\}//' ;;
  *)            echo "unknown command: $1 (try: $0 help)" >&2; exit 2 ;;
esac
