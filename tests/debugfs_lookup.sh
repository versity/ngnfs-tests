
#
# test lookup
#

t_require_commands ngnfs-cli

echo "== looking up files and directories with debugfs"
echo -e "mkfs\nlookup file\ncreate file\nlookup file\nmkdir dir\nlookup dir\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
