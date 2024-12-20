/* SPDX-License-Identifier: GPL-2.0 */

#include <unistd.h>
#include <limits.h>
#include <inttypes.h>

#include "shared/mount.h"
#include "shared/shutdown.h"
#include "shared/thread.h"

struct mount_umount_thread_args {
	int argc;
	char **argv;
	int ret;
};

static void mount_unmount_thread(struct thread *thr, void *arg)
{
	struct mount_umount_thread_args *margs = arg;
	struct ngnfs_fs_info nfi = INIT_NGNFS_FS_INFO;

	margs->ret = ngnfs_mount(&nfi, margs->argc, margs->argv);

	ngnfs_shutdown(&nfi, margs->ret);
	ngnfs_unmount(&nfi);
}

int main(int argc, char **argv)
{
	struct mount_umount_thread_args margs = {
		.argc = argc,
		.argv = argv,
	};
	struct thread thr;
	int ret;

	thread_init(&thr);

	ret = thread_prepare_main();
	if (ret < 0)
		goto out;

	ret = thread_start(&thr, mount_unmount_thread, &margs) ?:
	      thread_sigwait();

	thread_stop_wait(&thr);
out:
	thread_finish_main();

	return ret ?: margs.ret;
}

