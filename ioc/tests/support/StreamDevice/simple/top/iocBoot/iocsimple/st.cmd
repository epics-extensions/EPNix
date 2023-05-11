#!../../bin/linux-x86_64/simple

< envPaths

## Register all support components
dbLoadDatabase("../../dbd/simple.dbd", 0, 0)
simple_registerRecordDeviceDriver(pdbbase)

var streamError 1

epicsEnvSet("STREAM_PROTOCOL_PATH", ".:${TOP}/db")

drvAsynIPPortConfigure("PS1", "${STREAM_PS1}")

## Load record instances
dbLoadRecords("../../db/simple.db", "PORT=PS1")

iocInit()
