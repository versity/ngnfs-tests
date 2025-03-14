
#
# test that we can remove an xattr
#

t_require_commands ngnfs-cli

echo "== removing an xattr with debugfs"
echo -e "mkfs\nsetxattr . name value\ngetxattr . name\nremovexattr . name\ngetxattr . name\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace"
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
