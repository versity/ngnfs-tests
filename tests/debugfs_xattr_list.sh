
#
# test that we can list xattrs
#

t_require_commands ngnfs-cli

echo "== listing xattrs with debugfs"
echo -e "mkfs\nsetxattr . name value\nsetxattr . 1 1\nsetxattr . thing stuff\nlistxattr .\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace"
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
