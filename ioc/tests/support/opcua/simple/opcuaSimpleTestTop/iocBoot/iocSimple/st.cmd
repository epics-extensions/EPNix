#!../../bin/linux-x86_64/simple

#- You may have to change simple to something else
#- everywhere it appears in this file

< envPaths

cd "${TOP}"

## Register all support components
dbLoadDatabase "dbd/simple.dbd"
simple_registerRecordDeviceDriver pdbbase

## Load record instances
#dbLoadRecords("db/simple.db","user=vl276037")

cd "${TOP}/iocBoot/${IOC}"
iocInit

## Start any sequence programs
#seq sncxxx,"user=vl276037"
