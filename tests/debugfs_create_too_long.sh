
#
# test that creating a file with too long name fails
#

t_require_commands ngnfs-cli

echo "== creating a file with too long name with debugfs"
filename=`head -c 256 < /dev/zero | tr '\0' 'a'`
debugfs_cmd="mkfs\ncreate ${filename}\nstat ${filename}\nquit\n"
echo -e $debugfs_cmd | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
