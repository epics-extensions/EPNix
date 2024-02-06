#!../../bin/linux-x86_64/simple

#- You may have to change simple to something else
#- everywhere it appears in this file

< envPaths

## Register all support components
dbLoadDatabase "../../dbd/simple.dbd"
simple_registerRecordDeviceDriver(pdbbase)

## Load record instances
dbLoadRecords("${TOP}/db/simple.db", "P=PVXS:QSRV2:")

iocInit()

## Start any sequence programs
#seq sncsimple,"user=minijackson"
