
#
# test that we can request the number of bytes needed to list xattrs
#

t_require_commands ngnfs-cli

echo "== getting bytes needed to list xattrs with debugfs"
echo -e "mkfs\nsetxattr . name value\nsetxattr . 1 1\nsetxattr . thing stuff\nlistxattr . 0\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace"
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
