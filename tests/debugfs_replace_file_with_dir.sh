
#
# test renaming a dir over an existing file
#

t_require_commands ngnfs-cli

echo "== renaming a directory over a file with debugfs"
echo -e "mkfs\ncreate target\nmkdir dir\ncd dir\nmkdir target\nrename target\nstat target\ncd ..\nstat target\ncd target\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'

t_pass
