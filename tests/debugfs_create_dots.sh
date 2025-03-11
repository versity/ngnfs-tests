
#
# test that attempting to create/mkdir . and .. fails
#

t_require_commands ngnfs-cli

echo "== attempting to create/mkdir . and .."
echo -e "mkfs\ncreate .\ncreate ..\nmkdir .\nmkdir ..\nstat .\nstat ..\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed 's/time: [0-9].*/time: [REDACTED]/' | sed 's/ino: [0-9].*/ino: [REDACTED]/'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
