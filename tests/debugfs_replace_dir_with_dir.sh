
#
# test renaming a dir over an existing directory
#

t_require_commands ngnfs-cli

echo "== renaming a directory over a directory with debugfs"
echo -e "mkfs\nmkdir dir\nmkdir dir2\ncd dir\nmkdir dir2\ncd dir2\ncreate file\ncd ..\nrename dir2\nstat dir2\ncd ..\nstat dir2\ncd dir2\nstat file\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
