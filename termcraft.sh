# \\\CONFIG
# command prefix
# so a user can type (PREFIX)command and get the output of the supplied command in the conf file.
PREFIX="#"
TMUX_SESSION_NAME="steve"
CONF_FILENAME="termcraft.conf"

# \\\END OF CONFIG

# get list of oped users
# TODO: can probably AWK plain
OPTED=$(awk '/"name": / {print $2}' < ops.json | sed 's/[",]//g')

# get list of approved commands
declare -A commands
while read line; do
	IFS=: read k v <<< $line
	commands[$k]="$v"
done < "$CONF_FILENAME"

while true
do
	# pause to not overwhelm
	sleep 1
	# get most recent line from tmux buffer
	stat=$(tmux capture-pane -t $TMUX_SESSION_NAME -p | tail -n 2 | head -n 1)
	# Make sure nobody is impersonating
	l_brackets=$(echo "$stat" | grep -o "<" | wc -l)
	# check name
	name=$(echo "$stat" | grep -o "<.*>" | sed 's/[<>]//g')
	comm=$(echo "$stat" | grep -o ">.*$" | sed 's/> //')
	# default output
	output="INVALID COMMAND"

	# is name in opt list
	echo "$OPTED" | grep -q "$name"
	if [ $? = 1 ]; then
		continue
	fi

	# does the chat contain the $PREFIX ?
	echo "$comm" | grep -q "$PREFIX"
	if [ $? = 1 ]; then
		continue
	fi

	# comm without prefix :)
	scomm=$(echo "$comm" | sed "s/$PREFIX//")
	echo "$name: $comm"
	# did user type #marco
#	echo "$stat" | grep -q -e "#marco"
#	if [ $? = 1 ]; then
#		continue
#	fi
	# go through each command
	for k in "${!commands[@]}"
	do
		if [ "$k" = "$scomm" ]; then
			output=$(bash -c "${commands[$k]}")
		fi
	done

	# is there any other left angle brackets (<) check for impersonation
	if [ $l_brackets -ne 1 ]; then
		continue
	fi

	while IFS= read line; do
		stripline=$(echo "$line" | sed 's/"/\"/g')
		tmux send-keys -t $TMUX_SESSION_NAME "tellraw $name {\"text\": \"$stripline\"}" Enter
	done <<< "$output"
done
