
#
# test that we can't stat a non-existent file
#

t_require_commands ngnfs-cli

echo "== making a file system and stat-ing a non-existent file using debugfs"
echo -e "mkfs\nstat nonexistent\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace"
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
