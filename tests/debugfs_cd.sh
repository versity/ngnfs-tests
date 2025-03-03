
#
# test changing directories
#

t_require_commands ngnfs-cli

echo "== changing directories with debugfs"
echo -e "mkfs\ncd dir\nmkdir dir\nstat dir\ncd dir\nstat dir\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
