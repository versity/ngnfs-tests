
#
# test that creating a file succeeds
#

t_require_commands ngnfs-cli

echo "== creating a file with debugfs"
echo -e "mkfs\ncreate file\nstat file\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
