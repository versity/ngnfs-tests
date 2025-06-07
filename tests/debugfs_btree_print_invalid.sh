
#
# test printing btree block
#

t_require_commands ngnfs-cli

echo "== printing an invalid btree block"
echo -e "mkfs\n\nbtree_pb 1\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed -E 's/[0-9]+/[REDACTED]/g'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
