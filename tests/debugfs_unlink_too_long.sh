
#
# test that unlinking a directory entry with too long name fails
#

t_require_commands ngnfs-cli

echo "== unlinking a directory entry with too long name with debugfs"
direntname=`head -c 256 < /dev/zero | tr '\0' 'a'`
debugfs_cmd="mkfs\nunlink ${direntname}\nquit\n"
echo -e $debugfs_cmd | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
