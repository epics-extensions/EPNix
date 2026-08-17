#!../../bin/linux-x86_64/example

#- SPDX-FileCopyrightText: 2005 Argonne National Laboratory
#-
#- SPDX-License-Identifier: EPICS

< envPaths

## Register all support components
dbLoadDatabase("${TOP}/dbd/example.dbd")
example_registerRecordDeviceDriver(pdbbase)

## Load record instances
dbLoadRecords("${TOP}/db/example.db")
dbLoadRecords("${RECCASTER}/db/reccaster.db", "P=")

iocInit()
