
#
# test lookup of . and ..
#

t_require_commands ngnfs-cli

echo "== looking up . and .. with debugfs"
echo -e "mkfs\nlookup .\nlookup ..\nmkdir dir\ncd dir\nlookup .\nlookup ..\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
