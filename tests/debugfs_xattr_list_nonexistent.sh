
#
# test that we can't list a nonexistent xattr
#

t_require_commands ngnfs-cli

echo "== listing a nonexistent xattr with debugfs"
echo -e "mkfs\nlistxattr .\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace"
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
