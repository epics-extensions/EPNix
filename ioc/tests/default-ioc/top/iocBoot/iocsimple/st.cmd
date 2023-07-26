#!../../bin/linux-x86_64/simple

< envPaths

dbLoadDatabase "../../dbd/simple.dbd"
simple_registerRecordDeviceDriver(pdbbase)

dbLoadRecords("../../db/simple.db")

iocInit()
