
#
# test that we can make a file system with debugfs
#

t_require_commands ngnfs-cli

echo "== making a file system with debugfs"
echo -e "mkfs\nquit\n" | ngnfs-cli debugfs $T_MAPD_ADDRS -t "$T_TMPDIR/trace"
[ $? == 0 ] || t_fail "debugfs mkfs failed"

t_pass
