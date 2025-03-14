
#
# test that we can set an xattr with create flag
#

t_require_commands ngnfs-cli

echo "== setting an xattr with create flag with debugfs"
echo -e "mkfs\nsetxattr . name value create\ngetxattr . name\nsetxattr . name value create\ngetxattr . name\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace"
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
