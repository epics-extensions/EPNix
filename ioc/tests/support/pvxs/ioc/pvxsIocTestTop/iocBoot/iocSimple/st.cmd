#!../../bin/linux-x86_64/simple

< envPaths

epicsEnvSet("PREFIX", "autosave:test")

## Register all support components
dbLoadDatabase("$(TOP)/dbd/simple.dbd")
simple_registerRecordDeviceDriver(pdbbase)

iocInit()
