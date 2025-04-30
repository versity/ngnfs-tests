
#
# test renaming a file over another file
#

t_require_commands ngnfs-cli

echo "== renaming a file over a file with debugfs"
echo -e "mkfs\nmkdir dir\ncreate file\ncd dir\ncreate file\nwrite file 0 10\nrename file\nstat file\ncd ..\nstat file\nread file 0 10\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
