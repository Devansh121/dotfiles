#!/bin/sh
# After a restore, pre-type each pane's last command at its prompt without
# running it. Keyed on session:window.pane because pane ids (%5) are
# reassigned on restore and cannot be matched.

SIDECAR="/home/devansh/.local/share/tmux/resurrect/last-commands"
[ -f "$SIDECAR" ] || exit 0

TAB=$(printf '\t')

# Let the restored shells finish drawing their prompts. Keys delivered into a
# still-initializing pty get echoed by the tty AND redrawn by readline, which
# leaves the command smeared above the prompt. The input buffer is correct
# either way; this is purely so the pane looks clean.
sleep 2

while IFS="$TAB" read -r target cmd; do
	[ -n "$target" ] || continue
	[ -n "$cmd" ] || continue

	# Skip targets the restored layout doesn't have.
	tmux display -p -t "$target" '' >/dev/null 2>&1 || continue

	# Discard anything already buffered at the prompt before typing ours.
	tmux send-keys -t "$target" C-u 2>/dev/null

	# -l sends the text literally, so words like "Enter" or "C-c" inside a
	# command are not interpreted as keys. No Enter is sent: the command
	# sits at the prompt for the user to run or discard.
	tmux send-keys -t "$target" -l "$cmd" 2>/dev/null
done < "$SIDECAR"
