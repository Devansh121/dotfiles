#!/bin/sh
# Guarded wrapper around tmux-resurrect's save.sh.
# Every save path goes through here -- never call save.sh directly.

RS_DIR="/home/devansh/.local/share/tmux/resurrect"

# Restore rebuilds windows, which fires the same save hooks. Without this
# guard a restore-in-progress would overwrite a good snapshot with a
# half-rebuilt layout.
[ -e "$RS_DIR/.restoring" ] && exit 0

# Per-shell kill switch, in case the every-command save ever feels heavy:
#   export TMUX_RS_AUTOSAVE=0
[ "$TMUX_RS_AUTOSAVE" = "0" ] && exit 0

mkdir -p "$RS_DIR" 2>/dev/null

# Serialize saves: they fire from tmux hooks AND every shell prompt, so bursts
# overlap. -n (non-blocking) is the right policy -- a save already in flight
# makes this one redundant, so drop it rather than queue it.
flock -n "$RS_DIR/.savelock" \
	/home/devansh/.tmux/plugins/tmux-resurrect/scripts/save.sh

# Repair a dangling `last`.
#
# resurrect names snapshots to the second, and save.sh (lines 247-251) deletes
# its new file when the contents match `last`. Two saves in the SAME second
# therefore reuse one filename: the second run compares that file against
# `last`, which already points at it, concludes "identical", and removes it --
# leaving `last` pointing at nothing and the state unrestorable. Serializing
# does not help, because these saves are sequential, not concurrent.
#
# With a save per shell command, same-second saves are normal, so re-point
# `last` at the newest surviving snapshot whenever it breaks.
if [ -L "$RS_DIR/last" ] && [ ! -e "$RS_DIR/last" ]; then
	newest=$(ls -1t "$RS_DIR"/tmux_resurrect_*.txt 2>/dev/null | head -1)
	if [ -n "$newest" ]; then
		ln -fs "$(basename "$newest")" "$RS_DIR/last"
	else
		# The deleted file was the ONLY snapshot -- happens on the first save
		# after a wipe, when the hook save and the shell's first prompt save
		# land in the same second. Nothing to fall back to, so drop the broken
		# symlink and save again: with `last` gone, save.sh has nothing to
		# compare against and will write a fresh snapshot.
		rm -f "$RS_DIR/last"
		flock -n "$RS_DIR/.savelock" \
			/home/devansh/.tmux/plugins/tmux-resurrect/scripts/save.sh
	fi
fi

exit 0
