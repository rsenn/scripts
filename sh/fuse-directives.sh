# $Id: $
#
# Helper script which provides shell functions for every FUSE option.

debug() { debug=:; unset foreground; }
foreground() { [ "${debug+set}" != set ] && foreground=: ; }
single() { single=: ; }

allow_other() { allow_other=:; unset allow_root; }
allow_root() { allow_root=:; unset allow_other; }
nonempty() { nonempty=:; }
default_permissions() { default_permissions=:; }
fsname() { fsname="$*"; }
subtype() { subtype="$*"; }
large_read() { large_read=:; }
max_read() { max_read="$1"; }

hard_remove() { hard_remove=:; }
use_ino() { use_ino=:; }
readdir_ino() { readdir_ino=:; }
direct_io() { direct_io=:; }
kernel_cache() { kernel_cache=:; }
auto_cache() { auto_cache=:; }
noauto_cache() { unset auto_cache; }
umask() { umask="$*"; }
uid() { uid="$*"; }
gid() { gid="$*"; }
entry_timeout() { entry_timeout="$*"; }
negative_timeout() { negative_timeout="$*"; }
attr_timeout() { attr_timeout="$*"; }
ac_attr_timeout() { ac_attr_timeout="$*"; }
intr() { intr=:; }
intr_signal() { intr_signal="$*"; }
modules() { modules="$*"; }

max_write() { max_write="$*"; }
max_readahead() { max_readahead="$*"; }
async_read() { async_read=:; unset sync_read; }
sync_read() { sync_read=:; unset async_read; }

subdir() { subdir="$*"; }
rellinks() { rellinks=:; }
norellinks() { unset rellinks=:; }

from_code() { from_code="$*"; }
to_code() { to_code="$*"; }
