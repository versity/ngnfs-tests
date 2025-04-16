
#
# test that a big write works
#

t_require_commands ngnfs-cli

echo "== writing a lot of data with debugfs"
echo -e "mkfs\ncreate file\nwrite file 0 1000000\nread file 0 1000000\nstat file\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
