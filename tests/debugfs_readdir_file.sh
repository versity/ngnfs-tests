
#
# test readdir with one file
#

t_require_commands ngnfs-cli

echo "== reading directory with debugfs"
echo -e "mkfs\ncreate file\n\nreaddir\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
