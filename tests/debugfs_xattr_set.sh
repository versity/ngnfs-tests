
#
# test that we can set an xattr
#

t_require_commands ngnfs-cli

echo "== setting an xattr with debugfs"
echo -e "mkfs\nsetxattr . name value\ngetxattr . name\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace"
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
