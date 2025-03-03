
#
# test that removing a directory succeeds
#

t_require_commands ngnfs-cli

echo "== removing a directory with debugfs"
echo -e "mkfs\nmkdir dir\nstat dir\nrmdir dir\nstat dir\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
