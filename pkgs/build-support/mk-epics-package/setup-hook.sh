# Export this package in a EPNix specific "EPICS_COMPONENTS" environment variable,
# so that we are able to list every EPICS-specific packages,
# to add them in the 'configure/RELEASE.local' file
# in dependent packages.
export "EPICS_COMPONENTS=${EPICS_COMPONENTS:+${EPICS_COMPONENTS}:}@varname@=@out@"
