
#
# test renaming a file over an existing directory
#

t_require_commands ngnfs-cli

echo "== renaming a file over a directory with debugfs"
echo -e "mkfs\nmkdir dir\nmkdir target\ncd dir\ncreate target\nrename target\nstat target\ncd ..\nstat target\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
