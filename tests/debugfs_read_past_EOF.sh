
#
# test that reading past the end of a non-empty file returns EOF
#

t_require_commands ngnfs-cli

echo "== reading past the end of a non-empty file with debugfs"
echo -e "mkfs\ncreate file\nwrite file 0 10\nread file 10 10\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
