
#
# test that writing to a block requiring one indirect block works
#

t_require_commands ngnfs-cli

echo "== writing one indirect block of a file with debugfs"
echo -e "mkfs\ncreate file\nwrite file 5000 10\nread file 5000 10\nstat file\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
