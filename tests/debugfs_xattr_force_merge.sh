
#
# test that xattrs in btree will merge
#

t_require_commands ngnfs-cli

echo "== forcing a merge of btrees with debugfs"
xattr_value=`head -c 500 < /dev/zero | tr '\0' 'a'`
echo -e "mkfs\nsetxattr . 1 $xattr_value\nsetxattr . 2 $xattr_value\nsetxattr . 3 $xattr_value\nsetxattr . 4 $xattr_value\nsetxattr . 5 $xattr_value\nsetxattr . 6 $xattr_value\nsetxattr . 7 $xattr_value\nsetxattr . 8 $xattr_value\nsetxattr . 9 $xattr_value\nsetxattr . 10 $xattr_value\nlistxattr .\nremovexattr . 1\nremovexattr . 2\nremovexattr . 3\nremovexattr . 4\nremovexattr . 5\nremovexattr . 6\nremovexattr . 7\nlistxattr .\nquit\n" | ngnfs-cli debugfs $T_CLIENT_ADDRS -t "$T_TMPDIR/trace"
[ $? == 0 ] || t_fail "debugfs command failed"

t_pass
