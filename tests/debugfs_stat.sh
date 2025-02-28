
#
# test that we can stat the root inode via debugfs
#

t_require_commands ngnfs-cli

echo "== making a file system and stat-ing root inode with debugfs"
echo -e "mkfs\nstat\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
