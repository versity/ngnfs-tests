#!/usr/bin/bash

#
# SPDX-License-Identifier: GPL-2.0
#
# Adapted from the scoutfs tests: https://github.com/versity/scoutfs
#

#
# Uncomment below to debug safely - prints each command before
# executing. Does not affect called functions, so add to beginning of
# func to get traces from inside it.
#
# trap 'echo "[$BASH_SOURCE:$LINENO]: $BASH_COMMAND"; (read)' DEBUG
#

# force system tools to use ASCII quotes
export LC_ALL=C

msg() {
	echo "[== $@ ==]"
}

die() {
	msg "$@, exiting"
	exit 1
}

timestamp()
{
	date '+%F %T.%N'
}

# output a message with a timestamp to the run.log
log()
{
	echo "[$(timestamp)] $*" >> "$T_RESULTS/run.log"
}

# run a logged command, exiting if it fails
cmd() {
	log "$*"
	"$@" >> "$T_RESULTS/run.log" 2>&1 || \
		die "cmd failed (check the run.log)"
}

show_help()
{
cat << EOF
$(basename $0) options:
    -a        | Abort after the first test failure, leave fs mounted.
    -b <dir>  | Build and use ngnfs source located in dir
    -D <file> | Specify a device to use.  A devd server will be started for
	      | each device.  Will be clobbered by -m mkfs.
    -E <re>   | Exclude tests whose file name matches the regular expression.
              | Can be provided multiple times.
    -F        | Dump accumulated ftrace buffer to the console on oops.
    -I <re>   | Include tests whose file name matches the regular expression.
              | By default all tests are run.  If this is provided then
              | only tests matching will be run.  Can be provided multiple
              | times.
    -m        | Run mkfs on the device before mounting and running
              | tests.  Implies unmounting existing mounts first.
    -P        | Enable trace_printk.
    -p        | Exit script after preparing mounts only, don't run tests.
    -r <dir>  | Specify the directory in which to store results of
              | test runs.  The directory will be created if it doesn't
              | exist.  Previous results will be deleted as each test runs.
    -s        | Skip git repo checkouts.
    -T <nr>   | Multiply the original kernel trace buffer size by nr during
              | the run.
    -V <nr>   | Set mkfs device format version.
EOF
}

# TODO: support these options when possible:
#
#    -i        | Force removing and inserting the built ngnfs.ko module.
#    -M <nr>   | Number of mapd servers to start
#    -n <nr>   | The number of mounts to test.
#    -o <opts> | Add option string to all mounts during all tests.
#    -q <nr>   | How many mapd servers make a quorum

# unset all the T_ variables
for v in ${!T_*}; do
	eval unset $v
done

# set some T_ defaults
T_TRACE_DUMP="0"
T_TRACE_PRINTK="0"
#T_NR_MAPDS=1

# the port number is the start port - each additional server adds one to it
T_DEVD_HOST="127.0.0.1"
T_DEVD_PORT="8100"
#T_MAPD_HOST="127.0.0.1"
#T_MAPD_PORT="8200"

# array declarations to be able to use array ops
declare -a T_DEVICES

while true; do
	case $1 in
	-a)
		T_ABORT="1"
		;;
	-b)
		test -n "$2" || die "-b must have ngnfs source directory argument"
		T_NGNFS_PROGS="$2"
		shift
		;;
	-D)
		test -n "$2" || die "-D must have device file argument"
		T_DEVICES+=("$2")
		shift
		;;
	-E)
		test -n "$2" || die "-E must have test exclusion regex argument"
		T_EXCLUDE+="-e '$2' "
		shift
		;;
	-F)
		T_TRACE_DUMP="1"
		;;
	-I)
		test -n "$2" || die "-I must have test inclusion regex argument"
		T_INCLUDE+="-e '$2' "
		shift
		;;
	# -i)
	# 	T_INSMOD="1"
	# 	;;
	-m)
		T_MKFS="1"
		;;
	# -M)
	# 	test -n "$2" || die "-M must have nr mounts argument"
	# 	T_NR_MAPDS="$2"
	# 	shift
	# 	;;
	# -n)
	# 	test -n "$2" || die "-n must have nr mounts argument"
	# 	T_NR_MOUNTS="$2"
	# 	shift
	# 	;;
	# -o)
	# 	test -n "$2" || die "-o must have option string argument"
	# 	# always appending to existing options
	# 	T_MNT_OPTIONS+=",$2"
	# 	shift
	# 	;;
	-P)
		T_TRACE_PRINTK="1"
		;;
	-p)
		T_PREPARE="1"
		;;
	# -q)
	# 	test -n "$2" || die "-q must have quorum count argument"
	# 	T_QUORUM="$2"
	# 	shift
	# 	;;
	-r)
		test -n "$2" || die "-r must have results dir argument"
		T_RESULTS="$2"
		shift
		;;
	-s)
	        T_SKIP_CHECKOUT="1"
		;;
	-T)
		test -n "$2" || die "-T must have trace buffer size multiplier argument"
		T_TRACE_MULT="$2"
		shift
		;;
	-h|-\?|--help)
		show_help
		exit 1
		;;
	--)
		break
		;;
	-?*)
		printf 'WARN: Unknown option: %s\n' "$1" >&2
		show_help
		exit 1
		;;
	*)
		break
		;;
	esac

	shift
done

test -n "$T_DEVICES" || die "must specify -D device"
test -e "$T_DEVICES" || die "device -D '$T_DEVICES' doesn't exist"

test -n "$T_RESULTS" || die "must specify -r results dir"

# TODO: remove requirement to specify ngnfs-progs source when we have
# ngnfs-progs installed anywhere, but for now check and die
test -e "$T_NGNFS_PROGS" || die "must specify -b ngnfs-progs source directory"
test -d "$T_NGNFS_PROGS" || die "ngnfs-progs source $T_NGNFS_PROGS not a directory"

# test -n "$T_NR_MOUNTS" || die "must specify -n nr mounts"
# test "$T_QUORUM" -ge "1" || \
# 	 die "-q quorum mmembers must be at least 1"

# top level paths
T_TESTS=$(realpath "$(dirname $0)")

# canonicalize paths
# TODO: add T_KMOD when there is a kernel module
for e in T_DEVICES T_RESULTS T_NGNFS_PROGS; do
	eval $e=\"$(realpath "${!e}")\"
done

# include everything by default
test -z "$T_INCLUDE" && T_INCLUDE="-e '.*'"
# (quickly) exclude nothing by default
test -z "$T_EXCLUDE" && T_EXCLUDE="-e 'Zx'"

# using eval to strip regular expression ticks but not expand
tests=$(grep -v "^#" sequence |
	eval grep "$T_INCLUDE" | eval grep -v "$T_EXCLUDE")
test -z "$tests" && \
	die "no tests found by including $T_INCLUDE and excluding $T_EXCLUDE"

# create results dir
test -e "$T_RESULTS" || mkdir -p "$T_RESULTS"
test -d "$T_RESULTS" || \
	die "$T_RESULTS dir is not a directory"

# might as well build our stuff with all cpus, assuming idle system
MAKE_ARGS="-j $(getconf _NPROCESSORS_ONLN)"

# build kernel module
# msg "building kmod/ dir $T_KMOD"
# cmd cd "$T_KMOD"
# cmd make $MAKE_ARGS
# cmd cd -

# build userland progs if specified
if [ -n "$T_NGNFS_PROGS" ]; then
	msg "building ngnfs-progs/ dir $T_NGNFS_PROGS"
	cmd cd "$T_NGNFS_PROGS"
	cmd make $MAKE_ARGS
	cmd cd -

	# we can now run the built ngnfs-progs binaries, prefer over installed
	# TODO: should do this some other way than listing the individual dirs?
	for dir in cli devd; do
		PATH="$T_NGNFS_PROGS/$dir:$PATH"
	done
fi


msg "building test binaries"
cmd make C_INCLUDE_PATH="$T_NGNFS_PROGS" LIBRARY_PATH="$T_NGNFS_PROGS/lib" $MAKE_ARGS

# set any options implied by others
test -n "$T_MKFS" && T_UNMOUNT=1
#test -n "$T_INSMOD" && T_UNMOUNT=1

#
# We unmount all mounts because we might be removing the module.
#
# if [ -n "$T_UNMOUNT" ]; then
# 	umount -a -t ngnfs
# fi

# if [ -n "$T_INSMOD" ]; then
# 	msg "removing and reinserting ngnfs module"
#	# sync to disk before we potentially crash after loading the new module
#	cmd sync
# 	test -e /sys/module/ngnfs && cmd rmmod ngnfs
# 	T_MODULE="$T_KMOD/src/ngnfs.ko"
# 	cmd insmod "$T_MODULE"
# fi

if [ -n "$T_TRACE_MULT" ]; then
	orig_trace_size=$(cat /sys/kernel/debug/tracing/buffer_size_kb)
	mult_trace_size=$((orig_trace_size * T_TRACE_MULT))
	msg "increasing trace buffer size from $orig_trace_size KiB to $mult_trace_size KiB"
	echo $mult_trace_size > /sys/kernel/debug/tracing/buffer_size_kb
fi

if [ "$T_TRACE_PRINTK" != "0" ]; then
	echo "$T_TRACE_PRINTK" > /sys/kernel/debug/tracing/options/trace_printk
fi

if [ "$T_TRACE_DUMP" != "0" ]; then
	echo "$T_TRACE_DUMP" > /proc/sys/kernel/ftrace_dump_on_oops
fi

# always describe tracing in the logs
cmd cat /sys/kernel/debug/tracing/set_event
cmd grep .  /sys/kernel/debug/tracing/options/trace_printk \
	    /sys/kernel/debug/tracing/buffer_size_kb \
	    /proc/sys/kernel/ftrace_dump_on_oops

#
# stop all processes with a specified name listening on this and
# sequentially larger ports
#
# arguments: target_command_name hostname start_port
stop_port() {
	target=$1
	host=$2
	port=$3
	while true; do
		command=$(lsof -n -i @$host:$port +c0 | awk 'NR>1 {print $1}')
		# stop looking if nothing is using the port
		[ "$command" == "" ] && return
		[ "$command" != "$target" ] && die "unknown process $command using port $port"
		pid=$(lsof -n -i @$host:$port | awk 'NR>1 {print $2}')
		cmd kill -USR1 $pid
		cmd waitpid -t 5 -e $pid
		((port++))
	done
}

stop_devd() {
	msg "stopping all devd servers on port $T_DEVD_PORT and above"
	stop_port ngnfs-devd $T_DEVD_HOST $T_DEVD_PORT
}

start_devd() {
	msg "starting devd servers for ${T_DEVICES[@]}"
	cmd mkdir -p "$T_RESULTS/devd/"
	port="$T_DEVD_PORT"
	for d in "${T_DEVICES[@]}"; do
		addr="$T_DEVD_HOST:$port"
		cmd ngnfs-devd -d "$d" -l "$addr" -t "$T_RESULTS/devd/trace-$port" &
		T_DEVD_ADDRS="$T_DEVD_ADDRS -d $addr"
		((port++))
	done
}

# stop_mapd() {
# 	msg "stopping all mapd servers on port $T_MAPD_PORT and above"
# 	stop_port ngnfs-mapd $T_MAPD_HOST $T_MAPD_PORT
# }

# start_mapd() {
# 	msg "starting $T_NR_MAPDS mapd servers"
# 	cmd mkdir -p "$T_RESULTS/mapd/"
# 	port="$T_MAPD_PORT"
# 	for i in $(seq 0 $((T_NR_MAPDS - 1))); do
# 		addr="$T_MAPD_HOST:$port"
# 		mkdir -p "$T_RESULTS/mapd-storage-$port"
# 		# XXX put the output somewhere
# 		cmd ngnfs-mapd $T_DEVD_ADDRS -l "$addr" -t "$T_RESULTS/mapd/trace-$port" -s "$T_RESULTS/mapd/storage-$port"
# 		# collect command line options for ngnfs client
# 		T_MAPD_ADDRS="$T_MAPD_ADDRS -a $addr"
# 		((port++))
# 	done
# }

# TODO: have un_mkfs so the mkfs tests actually test making an fs

do_mkfs() {
	if [ -n "$T_MKFS" ]; then
		msg "making new file system"
		cmd echo -e "mkfs\nquit\n" | ngnfs-cli debugfs ${T_DEVD_ADDRS}
	fi
}

unmount_all() {
	if [ -n "$T_UNMOUNT" ]; then
		# cmd umount -t ngnfs
		msg "not unmounting any file systems, not supported yet"
	fi
}

mount_all() {
	# msg "mounting $T_NR_MOUNTS mounts with ${T_DEVICES[@]}"
	msg "not mounting any file systems, not supported yet"
}

do_shutdown() {
	unmount_all
	# TODO: un_mkfs
	# stop_mapd
	stop_devd
}

do_setup() {
	start_devd
	# start_mapd
	do_mkfs
	mount_all
	# tell ngnfs clients what addresses to connect to
	T_CLIENT_ADDRS="$T_DEVD_ADDRS"
}

# Shutdown any existing ngnfs servers and unmount if requested
do_shutdown

# we have some tests that want to do their own setup, so wait to do
# the setup till after them, unless we are asked to prepare and exit

if [ -n "$T_PREPARE" ]; then
	do_setup
	findmnt -t ngnfs
	msg "-p given, exiting after preparing file systems"
	exit 0
fi

# we need the STATUS definitions and filters
. funcs/exec.sh
. funcs/filter.sh

msg "running tests"
> "$T_RESULTS/skip.log"
> "$T_RESULTS/fail.log"

passed=0
skipped=0
failed=0
skipped_permitted=0

for t in $tests; do
	# after the no-setup tests, do the setup for setup-required tests
	if [ "$t" == "DO_SETUP" ]; then
		do_setup
		continue
	fi

	# tests has basenames from sequence, get path and name
	t="tests/$t"
	test_name=$(basename "$t" | sed -e 's/.sh$//')


	# create a temporary dir and file path for the test
	T_TMPDIR="$T_RESULTS/tmp/$test_name"
	T_TMP="$T_TMPDIR/tmp"
	cmd rm -rf "$T_TMPDIR"
	cmd mkdir -p "$T_TMPDIR"

	# # create a test name dir in the fs
	# T_DS=""
	# for i in $(seq 0 $((T_NR_MOUNTS - 1))); do
	# 	dir="${T_M[$i]}/test/$test_name"

	# 	test $i == 0 && cmd mkdir -p "$dir"

	# 	eval T_D$i=$dir
	# 	T_D[$i]=$dir
	# 	T_DS+="$dir "
	# done

	# export all our T_ variables
	for v in ${!T_*}; do
		eval export $v
	done
	export PATH # give test access to ngnfs-progs binaries

	# prepare to compare output to golden output
	test -e "$T_RESULTS/output" || cmd mkdir -p "$T_RESULTS/output"
	out="$T_RESULTS/output/$test_name"
	> "$T_TMPDIR/status.msg"
	golden="golden/$test_name"

	# get stats from previous pass
	last="$T_RESULTS/last-passed-test-stats"
	stats=$(grep -s "^$test_name " "$last" | cut -d " " -f 2-)
	test -n "$stats" && stats="last: $stats"

	printf "  %-30s $stats" "$test_name"

	# mark in dmesg as to what test we are running
	echo "run ngnfs test $test_name" > /dev/kmsg

	# record dmesg before
	dmesg | t_filter_dmesg > "$T_TMPDIR/dmesg.before"

	# give tests stdout and compared output on specific fds
	exec 6>&1
	exec 7>$out

	# run the test with access to our functions
	start_secs=$SECONDS
	bash -c "for f in funcs/*.sh; do . \$f; done; . $t" >&7 2>&1
	sts="$?"
	log "test $t exited with status $sts"
	stats="$((SECONDS - start_secs))s"

	# close our weird descriptors
	exec 6>&-
	exec 7>&-

	# compare output if the test returned passed status
	if [ "$sts" == "$T_PASS_STATUS" ]; then
		if [ ! -e "$golden" ]; then
			message="no golden output"
			sts=$T_FAIL_STATUS
		elif ! cmp -s "$golden" "$out"; then 
			message="output differs"
			sts=$T_FAIL_STATUS
			diff -u "$golden" "$out" >> "$T_RESULTS/fail.log"
		fi
	else
		# get message from t_*() functions
		message=$(cat "$T_TMPDIR/status.msg")
	fi

	# see if anything unexpected was added to dmesg
	if [ "$sts" == "$T_PASS_STATUS" ]; then
		dmesg | t_filter_dmesg > "$T_TMPDIR/dmesg.after"
		diff --old-line-format="" --unchanged-line-format="" \
			"$T_TMPDIR/dmesg.before" "$T_TMPDIR/dmesg.after" > \
			"$T_TMPDIR/dmesg.new"

		if [ -s "$T_TMPDIR/dmesg.new" ]; then
			message="unexpected messages in dmesg"
			sts=$T_FAIL_STATUS
			cat "$T_TMPDIR/dmesg.new" >> "$T_RESULTS/fail.log"
		fi
	fi

	# record unknown exit status
	if [ "$sts" -lt "$T_FIRST_STATUS" -o "$sts" -gt "$T_LAST_STATUS" ]; then
		message="unknown status: $sts"
		sts=$T_FAIL_STATUS
	fi

	# show and record the result of the test
	if [ "$sts" == "$T_PASS_STATUS" ]; then
		echo "  passed: $stats"
		((passed++))
		# save stats for passed test
		grep -s -v "^$test_name " "$last" > "$last.tmp"
		echo "$test_name $stats" >> "$last.tmp"
		mv -f "$last.tmp" "$last"
	elif [ "$sts" == "$T_SKIP_PERMITTED_STATUS" ]; then
		echo "  [ skipped (permitted): $message ]"
		echo "$test_name skipped (permitted) $message " >> "$T_RESULTS/skip.log"
		((skipped_permitted++))
	elif [ "$sts" == "$T_SKIP_STATUS" ]; then
		echo "  [ skipped: $message ]"
		echo "$test_name $message" >> "$T_RESULTS/skip.log"
		((skipped++))
	elif [ "$sts" == "$T_FAIL_STATUS" ]; then
		echo "  [ failed: $message ]"
		echo "$test_name $message" >> "$T_RESULTS/fail.log"
		((failed++))

		test -n "$T_ABORT" && die "aborting after first failure"
	fi
done

msg "all tests run: $passed passed, $skipped skipped, $skipped_permitted skipped (permitted), $failed failed"


if [ "$T_TRACE_PRINTK" != "0" ]; then
	msg "saving traces and disabling tracing"
	echo 0 > /sys/kernel/debug/tracing/options/trace_printk
	cat /sys/kernel/debug/tracing/trace > "$T_RESULTS/traces"
	if [ -n "$orig_trace_size" ]; then
		echo $orig_trace_size > /sys/kernel/debug/tracing/buffer_size_kb
	fi
fi

if [ "$skipped" == 0 -a "$failed" == 0 ]; then
	msg "all tests passed"
	do_shutdown
	exit 0
fi

if [ "$skipped" != 0 ]; then
	msg "$skipped tests skipped, check skip.log, still mounted"
fi
if [ "$failed" != 0 ]; then
	msg "$failed tests failed, check fail.log, still mounted"
fi
exit 1
