
#
# test that we can not get a nonexistent xattr
#

t_require_commands ngnfs-cli

echo "== getting a non-existent xattr with debugfs"
echo -e "mkfs\ngetxattr . name\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace"
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
