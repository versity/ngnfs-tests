#
# test that writing to random order offsets works
#

t_require_commands ngnfs-cli

echo "== writing to random order offsets in a file with debugfs"
echo -e "mkfs\ncreate file\nwrite file 5000 10\nread file 5000 10\nwrite file 2000000 10\nread file 2000000 10\nwrite file 0 10\nread file 0 10\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
