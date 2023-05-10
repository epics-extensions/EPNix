#!../../bin/linux-x86_64/simple

< envPaths

epicsEnvSet("PREFIX", "autosave:test")

## Register all support components
dbLoadDatabase("$(TOP)/dbd/simple.dbd")
simple_registerRecordDeviceDriver(pdbbase)

## Load record instances
dbLoadRecords("$(TOP)/db/autosave_test.db", "PREFIX=$(PREFIX)")

## Apply autosave configuration
set_requestfile_path("$(TOP)/iocBoot/$(IOC)")
set_savefile_path("/var/lib/epics/autosave")

#set_pass0_restoreFile("autosave_test.sav")
set_pass1_restoreFile("autosave_test.sav")

save_restoreSet_NumSeqFiles(1) # number of copies of each .sav file to maintain
save_restoreSet_SeqPeriodInSeconds(10) # interval between copies (in seconds)
save_restoreSet_RetrySeconds(5) # time delay (in seconds) between a failed .sav file write and the retry of that write
save_restoreSet_CAReconnect(1) # `1` to periodically (evry 60s) retry connecting to PVs whose initial connection attempt failed, `0` else
save_restoreSet_CallbackTimeout(-1) # time interval (in seconds) between forced save-file writes (-1 means forever),
                                    # this is intended to get save files written even if the normal trigger mechanism is broken

create_monitor_set("autosave_test.req", 5, "PREFIX=$(PREFIX)")

iocInit()

asVerify("autosave_test.sav")
