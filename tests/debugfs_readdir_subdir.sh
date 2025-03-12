
#
# test readdir with a directory as a child
#

t_require_commands ngnfs-cli

echo "== reading directory with a subdirectory with debugfs"
echo -e "mkfs\nreaddir\nmkdir dir\nreaddir\ncd dir\nreaddir\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
