This test suite runs tests for the ngnfs distributed file system on a
single system. ngnfs consists of three kinds of nodes: one or more
block servers (devd servers), cluster-wide information servers (mapd
servers), and clients that implement a file system on top of these
servers. The test suite starts all necessary servers to run the tests
on the local system.

## Invoking Tests

The basic test invocation has to specify where the ngnfs-progs source
is, where devices for the devd servers are, and where to put the
results. It will rebuild ngnfs-progs if necessary. You will need
superuser privileges to run the tests.

    $ sudo  ./run-tests.sh                      \
        -D /tmp/fake_dev0                       \
        -D /tmp/fake_dev1                       \
        -D /tmp/fake_dev2                       \
        -b ../ngnfs-progs/                      \
        -r ./results

All options can be seen by running with -h.

All tests will be run by default. Particular tests can be included or
excluded by providing test name regular expressions with the -I and -E
options. The definitive list of tests and the order in which they'll be
run is found in the sequence file.

## Individual Test Invocation

Each test is run in a new bash invocation. A set of directories in the
test volume and in the results path are created for the test. Each
test's working directory isn't managed.

Test output, temp files, and dmesg snapshots are all put in a tmp/ dir
in the results/ dir. Per-test dirs are only destroyed before each test
invocation.

The harness will check for unexpected output in dmesg after each
individual test.

Each test that fails will have its results appened to the fail.log file
in the results/ directory. The details of the failure can be examined
in the directories for each test in results/output/ and results/tmp/.

## Writing tests

This test suite is based on the scoutfs test suite. Many of the
features or options are commented out until the equivalent
functionality exists in ngnfs. Before writing a new test, check the
scoutfs repo to see if an equivalent test already exists and can be
ported over:

https://github.com/versity/scoutfs

Every test needs a test script, the golden output, and an entry in the
sequence file corresponding to the name of the script minus the
extension. The tests will be run in the order in the sequence file.

The framework supports two kinds of tests: tests that do all their own
setup and teardown, and those that rely on the test framework to do
the setup and assume an ngnfs file system exists and is accessible.
The two kinds are separated by a dummy entry in the sequence file
signaling that the test framework should do the setup at that point.

If necessary, you can add a file in src/ to build a custom binary, but
if possible please instead add a feature to ngnfs-cli debugfs that
does the same thing.

Tests have access to a set of t\_ prefixed bash functions that are found
in files in funcs/.

Tests complete by calling t\_ functions which indicate the result of the
test and can return a message. If the tests passes then its output is
compared with known good output. If the output doesn't match then the
test fails. The t\_ completion functions return specific status codes so
that returning without calling one can be detected.

The golden output has to be consistent across test platforms so there
are a number of filter functions which strip out local details from
command output. t\_filter\_fs is by far the most used which canonicalizes
fs mount paths and block device details.

Tests can be relatively loose about checking errors. If commands
produce output in failure cases then the test will fail without having
to specifically test for errors on every command execution. Care should
be taken to make sure that blowing through a bunch of commands with no
error checking doesn't produce catastrophic results. Usually tests are
simple and it's fine.

## Environment Variables

Tests have a number of exported environment variables that are commonly
used during the test.

| Variable         | Description          | Origin          | Example           |
| ---------------- | -------------------  | --------------- | ----------------- |
| T\_DEVICES[0-n]  | block devices        | -D              | /tmp/fake_dev0    |
| T\_DEVD\_HOST    | devd listen host     | var in script   | 127.0.0.1         |
| T\_MAPD\_HOST    | mapd listen host     | var in script   | 127.0.0.1         |
| T\_DEVD\_PORT    | devd start port      | var in script   | 8100              |
| T\_MAPD\_PORT    | mapd start port      | var in script   | 8200              |
| T\_TMP           | per-test tmp prefix  | made for test   | results/tmp/t/tmp |
| T\_TMPDIR        | per-test tmp dir dir | made for test   | results/tmp/t     |

There are also a number of variables that are set in response to options
and are exported but their use is rare so they aren't included here.

