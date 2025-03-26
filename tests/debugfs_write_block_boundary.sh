
#
# test that writing across a block boundary works
#

t_require_commands ngnfs-cli

echo "== writing across the boundary of block 1 and 2 with debugfs"
echo -e "mkfs\ncreate file\nwrite file 4090 10\nread file 4090 10\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
