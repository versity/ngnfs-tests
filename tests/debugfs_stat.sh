
#
# test that we can stat the root inode via debugfs
#

t_require_commands ngnfs-cli

echo "== making a file system with debugfs"
echo -e "mkfs\nquit\n" | ngnfs-cli debugfs $T_MAPD_ADDRS -t "$T_TMPDIR/trace"
[ $? == 0 ] || t_fail "debugfs mkfs failed"

echo ""
echo "== using debugfs to stat the root inode"
echo -e "stat\nquit\n" | ngnfs-cli debugfs $T_MAPD_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: /'
[ $? == 0 ] || t_fail "debugfs stat failed"

t_pass
