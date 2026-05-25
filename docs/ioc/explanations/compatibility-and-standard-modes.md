# Compatibility mode vs standard mode

EPNix is an "EPICS environment",
meaning a tool that allows packaging EPICS along with other EPICS-related projects
(thanks to the Nix package manager).

Typically, EPNix helps us create an "EPICS project", develop it, maintain it,
manage its dependencies, build it, deploy it, etc.

But within the EPICS community,
you might find different granularity level for what is considered an "EPICS" project.
I.e. some people will consider that a single App (or a single Sup) is a valid project
and will encourage versioning it in a dedicated Git repo,
in this case the Top will also be in an other dedicated repo
(some installations still have this legacy versioning method for historical reasons,
but this is quite rare nowadays).
While others will consider that a whole Top is better suited for versioning
(this seems to be the most modern/common versioning method amongst the EPICS community).

So, in order to accommodate both legacy and modern versioning methods,
it is important to know that EPNix supports two "modes":

:::{admonition} Compatibility mode
:class: warning

This mode is not recommended because it is not widely used within the EPICS community
(or very rarely).
This mode encourages versioning Tops, Apps, and Sups separately
in distinct Git repositories.
This is the historical mode of operation for some legacy projects
(and unfortunately also for less legacy ones).
This mode affects how your Top can be imported from another project,
because in this mode, Apps and Sups become separate dependencies
that are no longer specific to your Top
(they must therefore be imported separately).

:::

:::{admonition} Standard mode
:class: tip

This is the default recommended mode
because it is the most widely used within the EPICS community.
It simply involves versioning your Top
(and therefore all its content, including Apps and Sups)
in a single Git repository.
This mode makes your Top more standard to be imported by another project,
because it is sufficient to import the entire Top
in order to access the Apps and Sups it contains
(in the same way as is already done within the EPICS community when,
for example, using Asyn, StreamDevice, Modbus, etc).

:::

Note: You can develop a Top in standard mode
and import independently versioned Apps and Sups
(which were developed in compatibility mode).
Conversely, you can also develop in compatibility mode and import standard Tops.

In this documentation, both modes of operation will be systematically addressed
in order to handle any situation,
but the standard mode should be preferred whenever possible.
