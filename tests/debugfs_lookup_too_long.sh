
#
# test that looking up a too long directory entry name fails
#

t_require_commands ngnfs-cli

echo "== looking up a directory entry with too long name with debugfs"
filename=`head -c 256 < /dev/zero | tr '\0' 'a'`
debugfs_cmd="mkfs\nlookup ${filename}\nquit\n"
echo -e $debugfs_cmd | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
