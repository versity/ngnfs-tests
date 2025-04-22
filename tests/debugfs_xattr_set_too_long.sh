
#
# test that setting an xattr that is too long fails
#

t_require_commands ngnfs-cli

echo "== setting an xattr that is too long with debugfs"
xattr_value=`head -c 508 < /dev/zero | tr '\0' 'a'`
debugfs_cmd="mkfs\nsetxattr . a ${xattr_value}\ngetxattr . a\nquit\n"
echo -e ${debugfs_cmd} | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace"
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
