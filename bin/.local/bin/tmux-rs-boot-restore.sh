#!/bin/sh
# The single after-new-session handler: decides whether this new session should
# trigger a once-per-boot restore, then saves either way.
#
# This owns BOTH actions on purpose. Registering restore and save as two
# separate hooks meant tmux launched them concurrently (run-shell -b), so the
# save could test for the restore lock before the restore created it, write the
# near-empty brand-new session over the good snapshot, and leave restore
# reading back that emptiness. One script, one order, no race.

RS_DIR="/home/devansh/.local/share/tmux/resurrect"
MARKER="$RS_DIR/.last-boot"
LOCK="$RS_DIR/.restoring"
SAVE="/home/devansh/.local/bin/tmux-rs-save.sh"

BOOT_ID=$(cat /proc/sys/kernel/random/boot_id 2>/dev/null)

# Nothing to restore, or already restored for this boot -> just save normally.
if [ ! -e "$RS_DIR/last" ] || [ -z "$BOOT_ID" ] ||
	{ [ -f "$MARKER" ] && [ "$(cat "$MARKER" 2>/dev/null)" = "$BOOT_ID" ]; }; then
	exec "$SAVE"
fi

# Claim this boot BEFORE restoring: restore.sh creates sessions, which re-fires
# this very hook, and the marker makes those runs take the branch above.
printf '%s\n' "$BOOT_ID" > "$MARKER"

# Trap first, so a failure mid-restore can never leave saving disabled forever.
trap 'rm -f "$LOCK"' EXIT INT TERM HUP
: > "$LOCK"

/home/devansh/.tmux/plugins/tmux-resurrect/scripts/restore.sh
/home/devansh/.local/bin/tmux-rs-lastcmd.sh

# Drop the lock before saving, otherwise the wrapper no-ops.
rm -f "$LOCK"
trap - EXIT INT TERM HUP

"$SAVE"
