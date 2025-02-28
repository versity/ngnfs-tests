
#
# test that we can run the mount/unmount code
# currently does not require mkfs first
#

echo "== running ngnfs_mount/ngnfs_unmount"
./src/mount_unmount $T_CLIENT_ADDRS -t "$T_TMPDIR/trace"
[ $? == 0 ] || t_fail "mount/unmount failed"

t_pass
