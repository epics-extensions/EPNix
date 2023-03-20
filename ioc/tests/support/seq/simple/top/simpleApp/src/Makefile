TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS BELOW HERE

# Use typed rset structure (see 3.16.1 release notes)
USR_CPPFLAGS += -DUSE_TYPED_RSET

# Build the IOC application
PROD_IOC = simple

# simple.dbd will be created and installed
DBD += simple.dbd

# simple.dbd will include these files:
simple_DBD += base.dbd
simple_DBD += sncSimple.dbd

# simple_registerRecordDeviceDriver.cpp derives from simple.dbd
simple_SRCS += simple_registerRecordDeviceDriver.cpp
simple_SRCS += sncProgram.st

# Build the main IOC entry point where needed
simple_SRCS_DEFAULT += simpleMain.cpp
simple_SRCS_vxWorks += -nil-

simple_LIBS += seq pv

# Finally link IOC to the EPICS Base libraries
simple_LIBS += $(EPICS_BASE_IOC_LIBS)

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD EXTRA GNUMAKE RULES BELOW HERE

# Explicit dependency needed for generated header file
devsimpleVersion$(DEP): $(COMMON_DIR)/$(GENVERSION)
