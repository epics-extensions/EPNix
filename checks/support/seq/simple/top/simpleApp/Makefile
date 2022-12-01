# Makefile at top of application tree
TOP = ..
include $(TOP)/configure/CONFIG

# Directories to be built, in any order.
# You can replace these wildcards with an explicit list
DIRS += $(wildcard src* *Src*)
DIRS += $(wildcard db* *Db*)

include $(TOP)/configure/RULES_DIRS
