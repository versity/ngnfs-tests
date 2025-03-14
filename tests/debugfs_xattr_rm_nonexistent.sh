
#
# test that we can't remove a nonexistent xattr
#

t_require_commands ngnfs-cli

echo "== removing a nonexistent xattr with debugfs"
echo -e "mkfs\ngetxattr . name\nremovexattr . name\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace"
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
