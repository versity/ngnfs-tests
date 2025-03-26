
#
# test that writing to a block requring a double indirect block works
#

t_require_commands ngnfs-cli

echo "== writing a double indirect block of a file with debugfs"
echo -e "mkfs\ncreate file\nwrite file 2000000 10\nread file 2000000 10\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
