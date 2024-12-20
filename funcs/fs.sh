#
# The number of quorum members needed to form a majority.
#
t_majority_count()
{
	if [ "$T_QUORUM" -lt 3 ]; then
		echo 1
	else
		echo $(((T_QUORUM / 2) + 1))
	fi
}
