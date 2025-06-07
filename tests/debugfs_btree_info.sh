
#
# test getting btree info
#

t_require_commands ngnfs-cli

echo "== creating a file with debugfs and getting the directory btree info"
echo -e "mkfs\ncreate file\nbtree_info .\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace" | sed -E 's/[0-9]+/[REDACTED]/g'
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
