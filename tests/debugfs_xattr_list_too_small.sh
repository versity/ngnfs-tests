
#
# test that listing xattrs with too small a buf fails correctly
#

t_require_commands ngnfs-cli

echo "== getting bytes needed to list xattrs with debugfs"
echo -e "mkfs\nsetxattr . 1 1\nlistxattr . 1\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace"
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
