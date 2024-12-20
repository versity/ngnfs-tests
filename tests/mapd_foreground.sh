
#
# test that ngnfs-mapd works in foreground mode
#

t_require_commands ngnfs-mapd ngnfs-cli

echo "== testing that mapd server starts in foreground mode"
ngnfs-mapd -f -l "$T_MAPD_HOST:$T_MAPD_PORT" -d "$T_DEVD_HOST:$T_DEVD_PORT" -t "$T_TMPDIR/trace" -s "$T_TMPDIR/storage" &
p=$!

# wait for the port to open
for ((i=0; i<20; i++)); do
	command=$(lsof -n -i @$T_MAPD_HOST:$T_MAPD_PORT +c0 | awk 'NR>1 {print $1}')
	[ "$command" == ngnfs-mapd ] && break
	waitpid -t 0.1 $p
	[ "$?" != 1 ] || t_fail "mapd server exited unexpectedly"
done

[ "$command" == ngnfs-mapd ] || t_fail "ngnfs-mapd did not open port $T_MAPD_HOST:$T_MAPD_PORT"

echo "== cleanup"
kill -USR1 $p && waitpid -t 5 -e $p
[ "$?" == 0 ] || t_fail "couldn't kill mapd server"

t_pass
