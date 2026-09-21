-- Order matters:
--  1. remap  -> sets the leader key (must happen before lazy.nvim loads)
--  2. set    -> editor options
--  3. lazy   -> bootstraps the plugin manager + loads everything in lua/devansh/lazy/
require("devansh.remap")
require("devansh.set")
require("devansh.lazy_init")
