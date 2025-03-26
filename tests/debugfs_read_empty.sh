
#
# test that reading an empty file returns EOF
#

t_require_commands ngnfs-cli

echo "== reading an empty file with debugfs"
echo -e "mkfs\ncreate file\nread file 0 10\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
