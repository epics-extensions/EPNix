#!../../bin/linux-x86_64/simple

< envPaths

## Register all support components
dbLoadDatabase "${TOP}/dbd/simple.dbd"
simple_registerRecordDeviceDriver(pdbbase)

## Inspired by the reccaster demo IOC
epicsEnvSet("IOCNAME", "myioc")
epicsEnvSet("ENGINEER", "myself")
epicsEnvSet("LOCATION", "myplace")

epicsEnvSet("CONTACT", "mycontact")
epicsEnvSet("BUILDING", "mybuilding")
epicsEnvSet("SECTOR", "mysector")

addReccasterEnvVars("CONTACT", "SECTOR")
addReccasterEnvVars("BUILDING")

## Load record instances
dbLoadRecords("${TOP}/db/simple.db")

## Load RecCaster records
dbLoadRecords("${RECCASTER}/db/reccaster.db", "P=")

iocInit()
