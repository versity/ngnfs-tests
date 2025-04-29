
#
# test that we can set an xattr with replace flag
#

t_require_commands ngnfs-cli

echo "== setting an xattr with replace flag with debugfs"
echo -e "mkfs\nsetxattr . name value replace\ngetxattr . name\nsetxattr . name value create\ngetxattr . name\nsetxattr . name value2 replace\ngetxattr . name\nlistxattr .\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace"
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
