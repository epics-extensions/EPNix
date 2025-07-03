#include <epicsExport.h>
#include <initHooks.h>

#include <pvxs/iochooks.h>
#include <pvxs/nt.h>
#include <pvxs/server.h>
#include <pvxs/sharedpv.h>

// Adapted from the Adding custom PVs to Server here:
// https://mdavidsaver.github.io/pvxs/ioc.html#adding-custom-pvs-to-server

static void myinitHook(initHookState state)
{
    if (state != initHookAfterIocBuilt) {
        return;
    }

    // Must provide a data type for the mailbox.
    // Use pre-canned definition of scalar with meta-data
    pvxs::Value initial = pvxs::nt::NTScalar { pvxs::TypeCode::UInt32, true }.create();

    // (optional) Provide an initial value
    initial["value"] = 42u;
    initial["alarm.severity"] = 0;
    initial["alarm.status"] = 0;
    initial["alarm.message"] = "";
    initial["display.description"] = "My PV description";

    pvxs::server::SharedPV mypv(pvxs::server::SharedPV::buildMailbox());
    mypv.open(initial);

    pvxs::ioc::server().addPV("my:pv:name", mypv);
}

static void pvxs_ioc_registrar() { initHookRegister(&myinitHook); }

extern "C" {
epicsExportRegistrar(pvxs_ioc_registrar);
}
