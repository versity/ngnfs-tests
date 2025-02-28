/* SPDX-License-Identifier: GPL-2.0 */

#include <signal.h>
#include <unistd.h>
#include <limits.h>
#include <inttypes.h>

#include "shared/mount.h"
#include "shared/thread.h"

int main(int argc, char **argv)
{
	struct ngnfs_fs_info nfi = INIT_NGNFS_FS_INFO;
	struct thread thr;
	int ret;

	thread_init(&thr);

	ret = ngnfs_mount(&nfi, argc, argv);
	if (ret < 0)
		goto out;

	thread_stop_wait(&thr);
	ngnfs_unmount(&nfi);
	thread_finish_main();
out:
	return -ret;
}

