TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

PROD_IOC = simple
# simple.dbd will be created and installed
DBD += simple.dbd

# simple.dbd will be made up from these files:
simple_DBD += base.dbd

# simple_registerRecordDeviceDriver.cpp derives from simple.dbd
simple_SRCS += simple_registerRecordDeviceDriver.cpp

# Build the main IOC entry point on workstation OSs.
simple_SRCS_DEFAULT += simpleMain.cpp

# Finally link to the EPICS Base libraries
simple_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

