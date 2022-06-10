#!../../bin/linux-x86_64/simple

#- You may have to change simple to something else
#- everywhere it appears in this file

< envPaths

## Register all support components
dbLoadDatabase("../../dbd/simple.dbd",0,0)
simple_registerRecordDeviceDriver(pdbbase)

## Load record instances
dbLoadRecords("../../db/simple.db","user=myself")

iocInit()

## Start any sequence programs
#seq sncsimple,"user=minijackson"
