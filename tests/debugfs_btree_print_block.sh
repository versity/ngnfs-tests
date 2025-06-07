
#
# test printing btree block
#

t_require_commands ngnfs-cli

echo "== creating a file with debugfs and printing the directory btree"
echo -e "mkfs\ncreate file\nbtree_info .\nbtree_pb 4\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed -E 's/[0-9]+/[REDACTED]/g'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
