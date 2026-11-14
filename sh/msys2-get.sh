#!/bin/bash
#
# msys2-get.sh: install MSYS2/MinGW-w64 packages and their dependencies
# into a cross-toolchain sysroot, then check that every DLL resolves.
#
# Repos (https://repo.msys2.org/):
#   mingw64  mingw/mingw64  -> /usr/x86_64-w64-mingw32/sys*root/mingw  (tar root mingw64)
#   mingw32  mingw/mingw32  -> /usr/i686-w64-mingw32/sys*root/mingw    (tar root mingw32)
#   msys     msys/x86_64    -> /usr/x86_64-pc-msys/sys*root/usr        (tar root usr)
#   msys32   msys/i686      -> /usr/i686-pc-msys/sys*root/usr          (tar root usr)

: ${CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/msys2-get"}
: ${MIRROR=https://repo.msys2.org}
# makedepends that are host tools, not sysroot content
: ${SKIP_BUILD='-(cc|gcc.*|g\+\+|clang.*|toolchain|cmake.*|ninja|make|autotools|pkgconf|pkg-config|meson|python.*|perl|nasm|yasm|gettext-tools|ccache|binutils|windows-default-manifest|tools-git|headers-git|crt-git|winpthreads-git|libtool|autoconf.*|automake.*|m4|tcl|ruby|nodejs|rust|go)$'}

usage() {
  cat <<EOF 1>&2
Usage: ${0##*/} [OPTIONS] PACKAGE...

  -r, --repo REPO    mingw64 (default), mingw32, msys (msys64), msys32, or a host triplet.
                     Repeatable, also -rmsys32 -rmingw64 (so -r{msys,mingw}{32,64} works):
                     one run per repo, packages a repo lacks are skipped; not with -s
                     (x86_64-w64-mingw32, i686-w64-mingw32, x86_64-pc-msys, i686-pc-msys)
  -s, --sysroot S    a host triplet (expands to /usr/<triplet>/sysroot/{mingw,usr}
                     and selects the repo), or a directory; a directory under
                     /usr/<triplet>/ also selects the repo when --repo is not given
  -b, --build-deps   also install makedepends of the named packages
  -n, --no-deps      only the named packages, no dependencies
  -v, --version V    version of the named packages: newest (default), oldest,
                     or a version prefix such as 1.3.1 (needs the dir listing)
  -i, --pkginfo F    read depend (and with -b makedepend) lines of a .PKGINFO (- is
                     stdin) and treat them as named packages
  -L, --versions     list all versions available in the repo directory
  -D, --no-devel     msys repos split NAME and NAME-devel (headers, .a, .pc): the
                     -devel package of every named package is installed too, unless this is set
  -k, --keep-going   skip names that match no package instead of stopping (implied by
                     several -r)
  -f, --force        reinstall packages that are already installed
  -U, --urls         print the URL of every package that would be downloaded, one per
                     line, and stop (nothing is downloaded or installed)
  -S, --script       print a sh script that does the install with curl | zstd | tar
                     for every package (run it later, or on another machine)
  -N, --dry-run      print the install order and stop
  -u, --update       refresh the repo database
  -l, --list         list package names (matching the PACKAGE patterns)
  -V, --no-verify    skip the ntldd check
  -w, --wine         also start installed .exe with --version under wine
  -h, --help

PACKAGE is looked up loosely, first hit wins: the exact name with or without
the mingw-w64-<arch>- prefix, a provided name, lowercase and with the lib
prefix added or dropped, the alias table (lzma -> xz, magic -> file, pq ->
postgresql, see ALIAS in the script, more in $ALIASES), then a package whose
name starts with it (mariadb -> libmariadbclient). NAME-VERSION, NAME-oldest
and NAME-newest pin one package. The choice is printed as 'resolve'.
Environment: CACHE, MIRROR, SKIP_BUILD (regex of makedepends to ignore).
EOF
  exit "${1-0}"
}

die() { echo "${0##*/}: $*" 1>&2; exit 1; }
log() { echo "$*" 1>&2; }

# several -r: run once per repo (msys and mingw package names differ, so a
# name missing from one repo is skipped there, not an error)
REPOS=() REST=()
while [ $# -gt 0 ]; do
  case "$1" in
    -r | --repo) REPOS+=("$2"); shift 2 ;;
    --repo=*) REPOS+=("${1#--repo=}"); shift ;;
    -r?*) REPOS+=("${1#-r}"); shift ;;
    *) REST+=("$1"); shift ;;
  esac
done

if [ ${#REPOS[@]} -gt 1 ]; then
  for A in "${REST[@]}"; do
    case "$A" in -s | --sysroot | --sysroot=* | -s?*) die "--sysroot cannot be combined with several --repo" ;; esac
  done
  RC=0
  for R in "${REPOS[@]}"; do
    log "=== $R"
    MSYS2_GET_MULTI=1 "$0" -r "$R" "${REST[@]}" || RC=$?
  done
  exit $RC
fi
set -- "${REST[@]}"
[ ${#REPOS[@]} -eq 1 ] && set -- -r "${REPOS[0]}" "$@"

REPO=mingw64 SYSROOT= BUILD=false DEPS=true FORCE=false DRY=false UPDATE=false
LIST=false VERSIONS=false URLS=false SCRIPT=false NODEVEL=false PKGINFO= WANT=newest VERIFY=true WINE=false
PKGS=()

while [ $# -gt 0 ]; do
  case "$1" in
    -r | --repo) REPO=$2; shift 2 ;;
    -s | --sysroot) SYSROOT=$2; shift 2 ;;
    -b | --build-deps) BUILD=true; shift ;;
    -n | --no-deps) DEPS=false; shift ;;
    -v | --version) WANT=$2; shift 2 ;;
    -i | --pkginfo) PKGINFO=$2; shift 2 ;;
    -L | --versions) VERSIONS=true; shift ;;
    -D | --no-devel) NODEVEL=true; shift ;;
    -k | --keep-going) MSYS2_GET_MULTI=1; shift ;;
    -f | --force) FORCE=true; shift ;;
    -U | --urls) URLS=true; shift ;;
    -S | --script) SCRIPT=true; shift ;;
    -N | --dry-run) DRY=true; shift ;;
    -u | --update) UPDATE=true; shift ;;
    -l | --list) LIST=true; shift ;;
    -V | --no-verify) VERIFY=false; shift ;;
    -w | --wine) WINE=true; shift ;;
    -h | --help) usage 0 ;;
    --) shift; PKGS+=("$@"); break ;;
    -*) usage 1 ;;
    *) PKGS+=("$1"); shift ;;
  esac
done

# host triplet -> repo name
triplet_repo() {
  case "$1" in
    x86_64-w64-mingw32) echo mingw64 ;;
    i686-w64-mingw32) echo mingw32 ;;
    x86_64-pc-msys) echo msys ;;
    i686-pc-msys) echo msys32 ;;
    *) return 1 ;;
  esac
}

case "$REPO" in msys64) REPO=msys ;; mingw | x86_64) REPO=mingw64 ;; i686) REPO=mingw32 ;; esac
REPO_GIVEN=false
if R=$(triplet_repo "$REPO"); then REPO=$R; REPO_GIVEN=true; fi
[ "$REPO" != mingw64 ] && REPO_GIVEN=true

# --sysroot TRIPLET, or a path that contains one: the repo follows from it
if [ -n "$SYSROOT" ]; then
  if R=$(triplet_repo "$SYSROOT"); then
    $REPO_GIVEN && [ "$REPO" != "$R" ] && die "--repo $REPO does not match --sysroot $SYSROOT"
    REPO=$R SYSROOT=
  else
    for T in x86_64-w64-mingw32 i686-w64-mingw32 x86_64-pc-msys i686-pc-msys; do
      case "$SYSROOT/" in
        */$T/*) $REPO_GIVEN || REPO=$(triplet_repo $T); break ;;
      esac
    done
  fi
fi

case "$REPO" in
  mingw64) URLDIR=mingw/mingw64 ROOT=mingw64 PFX=mingw-w64-x86_64- TRIPLET=x86_64-w64-mingw32 SUB=mingw ;;
  mingw32) URLDIR=mingw/mingw32 ROOT=mingw32 PFX=mingw-w64-i686- TRIPLET=i686-w64-mingw32 SUB=mingw ;;
  msys) URLDIR=msys/x86_64 ROOT=usr PFX= TRIPLET=x86_64-pc-msys SUB=usr ;;
  msys32) URLDIR=msys/i686 ROOT=usr PFX= TRIPLET=i686-pc-msys SUB=usr ;;
  *) die "unknown repo $REPO" ;;
esac

if [ -z "$SYSROOT" ]; then
  for D in /usr/$TRIPLET/sysroot /usr/$TRIPLET/sys-root; do
    [ -d "$D" ] && { SYSROOT=$D/$SUB; break; }
  done
  [ -n "$SYSROOT" ] || die "no sysroot for $TRIPLET, pass --sysroot"
else
  # .../sysroot given without its mingw or usr part
  case "${SYSROOT%/}" in
    */sysroot | */sys-root) SYSROOT=${SYSROOT%/}/$SUB ;;
  esac
fi

for T in curl zstd tar awk sha256sum; do
  command -v "$T" >/dev/null || die "$T not found"
done

DB=$CACHE/$REPO
INDEX=$DB/index.tsv
mkdir -p "$DB/pkg" || die "cannot create the cache directory"

# index: name|filename|sha256|depends|makedepends|provides
# (lists are space separated, version constraints stripped)
update_db() {
  log "fetching $MIRROR/$URLDIR/$(db_name).db"
  curl -sfL "$MIRROR/$URLDIR/$(db_name).db" -o "$DB/db.tar.zst" || die "download of the repo database failed"
  rm -rf "$DB/desc"; mkdir -p "$DB/desc"
  zstd -d -c "$DB/db.tar.zst" | tar -C "$DB/desc" -xf - || die "cannot unpack the database"
  awk '
    function flush() {
      if (name != "") printf "%s|%s|%s|%s|%s|%s\n", name, file, sha, dep, mdep, prov
      name = file = sha = dep = mdep = prov = ""
    }
    FNR == 1 { flush() }
    /^%[A-Z0-9]+%$/ { sect = $0; next }
    NF == 0 { next }
    {
      v = $0; sub(/[<>=].*$/, "", v)
      if (sect == "%NAME%") name = $0
      else if (sect == "%FILENAME%") file = $0
      else if (sect == "%SHA256SUM%") sha = $0
      else if (sect == "%DEPENDS%") dep = dep " " v
      else if (sect == "%MAKEDEPENDS%") mdep = mdep " " v
      else if (sect == "%PROVIDES%") prov = prov " " v
    }
    END { flush() }
  ' "$DB"/desc/*/desc >"$INDEX.tmp" && mv "$INDEX.tmp" "$INDEX"
}

db_name() {
  case "$REPO" in
    mingw64 | mingw32) echo "$REPO" ;;
    msys | msys32) echo msys ;;
  esac
}

if $UPDATE || [ ! -s "$INDEX" ] || [ -n "$(find "$INDEX" -mtime +7 2>/dev/null)" ]; then
  update_db
fi

declare -A FILE SHA DEP MDEP PROV
while IFS="|" read -r N F S D M P; do
  FILE[$N]=$F SHA[$N]=$S DEP[$N]=$D MDEP[$N]=$M
  for X in $P; do PROV[$X]=${PROV[$X]:+${PROV[$X]} }$N; done
done <"$INDEX"

if $LIST; then
  for N in "${!FILE[@]}"; do
    if [ ${#PKGS[@]} -eq 0 ]; then echo "$N"; continue; fi
    for P in "${PKGS[@]}"; do [[ $N == *$P* ]] && { echo "$N"; break; }; done
  done | sort
  exit 0
fi

# alias: loose name -> package name (the names a build system uses are not
# always the package names); more lines "name=package" in $ALIASES
declare -A ALIAS=(
  [lzma]=xz [liblzma]=xz [bz2]=bzip2 [libbz2]=bzip2
  [magic]=file [libmagic]=file
  [pq]=postgresql [libpq]=postgresql [pgsql]=postgresql
  [mariadb]=libmariadbclient [libmariadb]=libmariadbclient [mysql]=libmariadbclient
  [sqlite3]=sqlite [libsqlite3]=sqlite [crypto]=openssl [ssl]=openssl [libressl]=openssl
  [ressl]=openssl [z]=zlib [libz]=zlib [lzo]=lzo2 [liblzo2]=lzo2 [b2]=libb2
)
: ${ALIASES=$HOME/.config/msys2-get/aliases}
if [ -f "$ALIASES" ]; then
  while IFS='=' read -r K V; do
    [ -n "$K" ] && [[ $K != \#* ]] && ALIAS[$K]=$V
  done <"$ALIASES"
fi

# exact package name, or provided name, for one spelling
lookup_exact() {
  local C
  for C in "$1" "$PFX$1"; do
    [ -n "${FILE[$C]+x}" ] && { echo "$C"; return 0; }
  done
  for C in "$1" "$PFX$1"; do
    [ -n "${PROV[$C]}" ] && { echo "${PROV[$C]%% *}"; return 0; }
  done
  return 1
}

# NAME [note]: canonical package name for a name as a build system spells it.
# Tried in order, the first hit wins:
#   1 exact name or provided name      zlib, mingw-w64-x86_64-zlib
#   2 lowercase, lib prefix off/on     LibZ -> libz -> z
#   3 alias table                      lzma -> xz, magic -> file
#   4 widen: a package whose name starts with the token (or lib + token),
#     the shortest wins              mariadb -> libmariadbclient
# With note set, a match from step 3 or 4 is reported on stderr.
lookup() {
  local A=${1,,} V C R N
  local -a VARS=("$1" "$A")
  [[ $A == lib* ]] && VARS+=("${A#lib}") || VARS+=("lib$A")
  for V in "${VARS[@]}"; do
    R=$(lookup_exact "$V") && { echo "$R"; return 0; }
  done
  for V in "${VARS[@]}"; do
    C=${ALIAS[$V]}
    [ -n "$C" ] && R=$(lookup_exact "$C") && { [ -n "$2" ] && log "resolve   $1 -> $R (alias)"; echo "$R"; return 0; }
  done
  R=
  for V in "${VARS[@]}"; do
    for N in "${!FILE[@]}"; do
      C=${N#$PFX}
      [[ -z $PFX || $N == $PFX* ]] || continue
      if [[ $C == $V* || $C == lib$V* ]]; then
        [ -z "$R" ] || [ ${#N} -lt ${#R} ] && R=$N
      fi
    done
    [ -n "$R" ] && break
  done
  [ -n "$R" ] || return 1
  [ -n "$2" ] && log "resolve   $1 -> $R (widened)"
  echo "$R"
}

# all package files in the repo directory, version sorted: listed once, then
# every search runs on the cached file (list-ftp.sh, curl fallback)
dir_files() {
  local D=$DB/dir.txt
  if [ ! -s "$D" ] || $UPDATE; then
    log "listing $MIRROR/$URLDIR/"
    if command -v list-ftp.sh >/dev/null; then
      list-ftp.sh "$MIRROR/$URLDIR/"
    else
      curl -sfL "$MIRROR/$URLDIR/" | grep -o 'href="[^"]*"' | sed 's,href="\(.*\)",\1,'
    fi | sed 's,.*/,,' | grep '\.pkg\.tar\.zst$' | sort -V >"$D.tmp" && mv "$D.tmp" "$D"
  fi
  cat "$D"
}

# name of a package file: drop -version-release-arch.pkg.tar.zst
file_name() { local B=${1%.pkg.tar.zst}; B=${B%-*}; B=${B%-*}; echo "${B%-*}"; }
file_version() { local B=${1%.pkg.tar.zst}; B=${B%-*}; B=${B%-*}; echo "${B##*-}"; }

# lower versions first: all files of package $1, optionally only version prefix $2
versions_of() {
  local F E
  E=$(echo "$1" | sed 's/[][\.*^$+?(){}|]/\\&/g')
  dir_files >/dev/null
  while read -r F; do
    [ "$(file_name "$F")" = "$1" ] || continue
    [ -z "$2" ] || [[ $(file_version "$F") == $2* ]] || continue
    echo "$F"
  done < <(grep -E "^$E-[0-9]" "$DB/dir.txt")
}

# names from a .PKGINFO: depend lines, plus makedepend lines with -b
if [ -n "$PKGINFO" ]; then
  KINDS='depend'
  $BUILD && KINDS='depend|makedepend'
  while read -r D; do
    [[ $D =~ $SKIP_BUILD ]] && continue
    PKGS+=("$D")
  done < <(sed -n -E "s/^($KINDS) = ([^<>=]*).*/\2/p" <"${PKGINFO/#-//dev/stdin}" | sed 's/ *$//')
fi
[ ${#PKGS[@]} -gt 0 ] || usage 1

# resolve every argument to a package name once, here, in the main shell:
# NAME, or NAME-VERSION / NAME-oldest / NAME-newest (version for that package only)
declare -A PIN
NAMES=()
for P in "${PKGS[@]}"; do
  V= R=$(lookup "$P" note)
  if [ -z "$R" ] && [[ $P =~ ^(.+)-([0-9][^-]*|oldest|newest)$ ]]; then
    V=${BASH_REMATCH[2]}
    R=$(lookup "${BASH_REMATCH[1]}" note)
  fi
  if [ -z "$R" ]; then
    [ -n "$MSYS2_GET_MULTI" ] && { log "skip      $P (not in $REPO)"; continue; }
    die "package not found: $P"
  fi
  [ -n "$V" ] && PIN[$R]=$V
  NAMES+=("$R")
done

# msys packages keep headers, import libraries and .pc files in NAME-devel
if [[ $REPO == msys* ]] && ! $NODEVEL; then
  for N in "${NAMES[@]}"; do
    [ -n "${FILE[$N-devel]+x}" ] || continue
    [[ " ${NAMES[*]} " == *" $N-devel "* ]] || NAMES+=("$N-devel")
  done
fi

# extended regex matching the package files of all named packages
filter_pattern() {
  local N ALT=
  for P in "$@"; do
    N=$(lookup "$P") || N=$PFX$P
    N=$(echo "$N" | sed 's/[][\.*^$+?(){}|]/\\&/g')
    ALT=${ALT:+$ALT|}$N
  done
  echo "(^|/)($ALT)-[0-9][^-]*-[0-9]+-[a-z0-9_]+\\.pkg\\.tar\\.zst\$"
}

if $VERSIONS || { $DRY && [ -n "$PKGINFO" ]; }; then
  [ ${#NAMES[@]} -gt 0 ] || exit 0
  PAT=$(filter_pattern "${NAMES[@]}")
  log "filter: list-ftp.sh $MIRROR/$URLDIR/ | grep -E '$PAT'"
  $VERSIONS && { dir_files | grep -E "$PAT"; exit 0; }
fi

# the file for a named package when --version is not newest: depends come
# from the package's own .PKGINFO, there is no sha256 in the repo database
pin_version() {
  local N=$1 W=${PIN[$1]:-$WANT} F
  case "$W" in
    newest) return 0 ;;
    oldest) F=$(versions_of "$N" | head -n1) ;;
    *) F=$(versions_of "$N" "$W" | tail -n1) ;;
  esac
  [ -n "$F" ] || { [ -n "$MSYS2_GET_MULTI" ] && { log "skip      $N ($W: no such version)"; return 1; }; die "no $W version of $N in the repo directory"; }
  [ "$F" = "${FILE[$N]}" ] && return 0
  FILE[$N]=$F SHA[$N]=
  fetch_pkg "$N"
  DEP[$N]=$(zstd -d -c "$DB/pkg/$F" | tar -xOf - .PKGINFO | sed -n 's/^depend = \([^<>=]*\).*/\1/p' | tr '\n' ' ')
  MDEP[$N]=$(zstd -d -c "$DB/pkg/$F" | tar -xOf - .PKGINFO | sed -n 's/^makedepend = \([^<>=]*\).*/\1/p' | tr '\n' ' ')
}

fetch_pkg() {
  local N=$1 F=${FILE[$1]} S=${SHA[$1]} PKG=$DB/pkg/${FILE[$1]}
  if [ ! -s "$PKG" ] || { [ -n "$S" ] && [ "$(sha256sum <"$PKG" | cut -d' ' -f1)" != "$S" ]; }; then
    curl -sfL "$MIRROR/$URLDIR/$F" -o "$PKG.part" || { rm -f "$PKG.part"; die "download of $F failed"; }
    [ -z "$S" ] || [ "$(sha256sum <"$PKG.part" | cut -d' ' -f1)" = "$S" ] || { rm -f "$PKG.part"; die "sha256 mismatch for $F"; }
    mv "$PKG.part" "$PKG"
  fi
}

declare -A SEEN WHY
ORDER=()
MISSING=()

# post-order walk: dependencies are appended before their dependants
visit() {
  local N=$1 D R
  [ -n "${SEEN[$N]}" ] && return
  SEEN[$N]=1; WHY[$N]=$2
  if $DEPS; then
    for D in ${DEP[$N]}; do
      R=$(lookup "$D") || { MISSING+=("$D (needed by $N)"); continue; }
      visit "$R" "$N"
    done
  fi
  ORDER+=("$N")
}

installed() { [ -f "$SYSROOT/.msys2-get/$1.files" ]; }

for R in "${NAMES[@]}"; do
  pin_version "$R" || continue
  visit "$R"
  if $BUILD; then
    for D in ${MDEP[$R]}; do
      [[ $D =~ $SKIP_BUILD ]] && continue
      R2=$(lookup "$D") || { MISSING+=("$D (build dependency of $R)"); continue; }
      visit "$R2"
    done
  fi
done

for M in "${MISSING[@]}"; do log "warning: unresolved dependency $M"; done

TODO=()
for N in "${ORDER[@]}"; do
  if installed "$N" && ! $FORCE; then
    log "have      $N"
  else
    TODO+=("$N")
    log "install   $N  (${FILE[$N]})${WHY[$N]:+  needed by ${WHY[$N]}}"
  fi
done
$DRY && exit 0

if $URLS; then
  for N in "${TODO[@]}"; do echo "$MIRROR/$URLDIR/${FILE[$N]}"; done
  exit 0
fi

# one curl | zstd | tar line per package, dependencies first; the .pc
# files are pointed at the sysroot at the end, as an install here would
if $SCRIPT; then
  echo '#!/bin/sh'
  echo "# generated by ${0##*/}: ${PKGS[*]} ($REPO, ${#TODO[@]} packages)"
  echo "SYSROOT=\${SYSROOT:-$SYSROOT}"
  echo 'set -e'
  echo 'mkdir -p "$SYSROOT"'
  for N in "${TODO[@]}"; do
    echo "# $N${SHA[$N]:+ sha256 ${SHA[$N]}}"
    echo "curl -sfL $MIRROR/$URLDIR/${FILE[$N]} | zstd -d -c | tar -C \"\$SYSROOT\" --strip-components=1 -x $ROOT"
  done
  echo "find \"\$SYSROOT\" -path '*/pkgconfig/*.pc' -exec sed -i \"s,^prefix=/$ROOT\\\$,prefix=\$SYSROOT,\" {} +"
  exit 0
fi

install_pkg() {
  local N=$1 F=${FILE[$1]} PKG LST
  PKG=$DB/pkg/$F
  fetch_pkg "$N"
  LST=$SYSROOT/.msys2-get/$N.files
  # only the tree below $ROOT/ belongs in the sysroot (.PKGINFO, .MTREE stay out)
  zstd -d -c "$PKG" | tar -C "$SYSROOT" --strip-components=1 -xv "$ROOT" 2>/dev/null |
    sed -n 's,^[^/]*/,,p' >"$LST.tmp" || die "extracting $F failed"
  mv "$LST.tmp" "$LST"
  rewrite_pc "$LST"
}

# .pc files carry prefix=/mingw64 (or /usr): point them at the sysroot
rewrite_pc() {
  local F
  while read -r F; do
    case "$F" in
      */pkgconfig/*.pc)
        [ -f "$SYSROOT/$F" ] && sed -i "s,^\(prefix=\)/$ROOT\$,\1$SYSROOT," "$SYSROOT/$F" ;;
    esac
  done <"$1"
}

mkdir -p "$SYSROOT/.msys2-get" || die "cannot create $SYSROOT/.msys2-get"
NEW=()
for N in "${TODO[@]}"; do
  install_pkg "$N"
  NEW+=("$SYSROOT/.msys2-get/$N.files")
  log "installed $N"
done

$VERIFY || exit 0

# DLLs every Windows has: not found on this machine by design
SYSDLL='^(kernel32|kernelbase|ntdll|user32|gdi32|advapi32|shell32|shlwapi|ole32|oleaut32|ws2_32|wsock32|mswsock|msvcrt|ucrtbase|crypt32|bcrypt|ncrypt|secur32|iphlpapi|winmm|comctl32|comdlg32|imm32|version|setupapi|userenv|wininet|winhttp|psapi|dbghelp|netapi32|dnsapi|rpcrt4|uxtheme|dwmapi|shcore|cfgmgr32|mpr|wldap32|normaliz|powrprof|imagehlp|opengl32|glu32|d3d9|d3d11|dxgi|api-ms-win-.*|ext-ms-win-.*|msys-2\.0|cygwin1)\.dll$'

if ! command -v ntldd >/dev/null; then
  log "ntldd not found, skipping the check"
  exit 0
fi

BAD=0 CHECKED=0
for L in "${NEW[@]}"; do
  [ -f "$L" ] || continue
  while read -r F; do
    case "$F" in
      *.dll | *.exe) ;;
      *) continue ;;
    esac
    [ -f "$SYSROOT/$F" ] || continue
    CHECKED=$((CHECKED + 1))
    while read -r DLL ARROW REST; do
      [ "$ARROW" = "=>" ] || continue
      case "$REST" in "not found"*) ;; *) continue ;; esac
      LOW=$(echo "$DLL" | tr 'A-Z' 'a-z')
      [[ $LOW =~ $SYSDLL ]] && continue
      [ -n "$(find "$SYSROOT/bin" -maxdepth 1 -iname "$DLL" -print -quit 2>/dev/null)" ] && continue
      echo "UNRESOLVED  $F  needs  $DLL" 1>&2
      BAD=$((BAD + 1))
    done < <(ntldd -D "$SYSROOT/bin" "$SYSROOT/$F" 2>/dev/null)
  done <"$L"
done
log "ntldd: $CHECKED binaries checked, $BAD unresolved"

if $WINE && command -v wine >/dev/null; then
  for L in "${NEW[@]}"; do
    while read -r F; do
      case "$F" in */bin/*.exe) ;; *) continue ;; esac
      if WINEPATH=$(winepath -w "$SYSROOT/${F%/*}" 2>/dev/null) WINEDEBUG=-all \
        timeout 20 wine "$SYSROOT/$F" --version >/dev/null 2>&1 </dev/null; then
        log "wine ok     $F"
      else
        log "wine FAILED $F"
        BAD=$((BAD + 1))
      fi
    done <"$L"
  done
fi

[ $BAD -eq 0 ]
