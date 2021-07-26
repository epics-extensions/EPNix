TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS BELOW HERE

# Use typed rset structure (see 3.16.1 release notes)
USR_CPPFLAGS += -DUSE_TYPED_RSET

# xxxRecord.h will be created from xxxRecord.dbd
DBDINC += xxxRecord

# Install xxxSupport.dbd into <top>/dbd
DBD += xxxSupport.dbd

# Build an IOC support library
LIBRARY_IOC += myExampleSupport

# Compile and add code to the support library
myExampleSupport_SRCS += xxxRecord.c
myExampleSupport_SRCS += devXxxSoft.c

# Link locally-provided code into the support library,
# rather than directly into the IOC application, that
# causes problems on Windows DLL builds
myExampleSupport_SRCS += dbSubExample.c
myExampleSupport_SRCS += devmyExampleVersion.c
myExampleSupport_SRCS += myExampleHello.c
myExampleSupport_SRCS += initTrace.c

myExampleSupport_LIBS += $(EPICS_BASE_IOC_LIBS)

# Auto-generate a header file containing a version string.
# Version comes from the VCS if available, else date+time.
GENVERSION = myExampleVersion.h
# Macro name
GENVERSIONMACRO = myExampleVERSION

# Build the IOC application
PROD_IOC = myExample

# myExample.dbd will be created and installed
DBD += myExample.dbd

# myExample.dbd will include these files:
myExample_DBD += base.dbd
myExample_DBD += xxxSupport.dbd
myExample_DBD += dbSubExample.dbd
myExample_DBD += devmyExampleVersion.dbd
myExample_DBD += myExampleHello.dbd
myExample_DBD += initTrace.dbd

# myExample_registerRecordDeviceDriver.cpp derives from myExample.dbd
myExample_SRCS += myExample_registerRecordDeviceDriver.cpp

# Build the main IOC entry point where needed
myExample_SRCS_DEFAULT += myExampleMain.cpp
myExample_SRCS_vxWorks += -nil-

# Link in the code from our support library
myExample_LIBS += myExampleSupport

# To build SNL programs, SNCSEQ must be defined
# in the <top>/configure/RELEASE file
ifneq ($(SNCSEQ),)
    # Build sncExample into myExampleSupport
    sncExample_SNCFLAGS += +r
    myExample_DBD += sncExample.dbd
    # A .stt sequence program is *not* pre-processed:
    myExampleSupport_SRCS += sncExample.stt
    myExampleSupport_LIBS += seq pv
    myExample_LIBS += seq pv

    # Build sncProgram as a standalone program
    PROD_HOST += sncProgram
    sncProgram_SNCFLAGS += +m
    # A .st sequence program *is* pre-processed:
    sncProgram_SRCS += sncProgram.st
    sncProgram_LIBS += seq pv
    sncProgram_LIBS += $(EPICS_BASE_HOST_LIBS)
endif

# Link QSRV (pvAccess Server) if available
ifdef EPICS_QSRV_MAJOR_VERSION
    myExample_LIBS += qsrv
    myExample_LIBS += $(EPICS_BASE_PVA_CORE_LIBS)
    myExample_DBD += PVAServerRegister.dbd
    myExample_DBD += qsrv.dbd
endif

# Finally link IOC to the EPICS Base libraries
myExample_LIBS += $(EPICS_BASE_IOC_LIBS)

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD EXTRA GNUMAKE RULES BELOW HERE

# Explicit dependency needed for generated header file
devmyExampleVersion$(DEP): $(COMMON_DIR)/$(GENVERSION)
