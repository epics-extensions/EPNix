# Glossary

::::{glossary}
**Nix**
  Nix is a cross-platform package manager claiming to be:

  - Reproducible.
    I.e. Nix builds packages in isolation from each other.
    This ensures that they are reproducible and don't have undeclared dependencies,
    so if a package works on one machine, it will also work on another.
  - Declarative.
    I.e. Nix makes it trivial to share development and build environments for your projects,
    regardless of what programming languages and tools you’re using.
  - Reliable.
    I.e. Nix ensures that installing or upgrading one package cannot break other packages.
    It allows you to roll back to previous versions,
    and ensures that no package is in an inconsistent state during an upgrade.

  Nix is is also the name of the programming language used by the package manager.

  :::{seealso}

  - <https://nixos.wiki/wiki/Nix_package_manager>
  - <https://nixos.wiki/wiki/Overview_of_the_Nix_Language>
  - <https://nixos.wiki/wiki/Nix_Ecosystem>

  :::

**NixOS**
  NixOS is a Linux distribution based on the Nix package manager and build system.
  All components of this distribution — including the kernel,
  installed packages and system configuration files —
  are built by Nix from "pure functions" called Nix expressions.

  :::{seealso}

  - <https://nixos.wiki/wiki/Overview_of_the_NixOS_Linux_distribution>
  - <https://nixos.wiki/wiki/Nix_Ecosystem>
  - <https://nixos.org/>

  :::

**Nixpkgs**
  Nixpkgs claims to be the largest repository of Nix packages and NixOS modules.
  The repository is hosted on GitHub and maintained by the community,
  with official backing from the NixOS Foundation.

  :::{seealso}

  - <https://nixos.wiki/wiki/Nixpkgs>
  - <https://nixos.wiki/wiki/Nix_Ecosystem>

  :::

**EPICS**
  **E**xperimental **P**hysics and **I**ndustrial **C**ontrol **S**ystem.
  EPICS is a set of software tools and applications
  which provide a software infrastructure
  for use in building distributed control systems
  to operate devices such as
  Particle Accelerators, Large Experiments and major Telescopes.
  Such distributed control systems typically comprise tens or even hundreds of computers,
  networked together to allow communication between them
  and to provide control and feedback of the various parts of the device
  from a central control room,
  or even remotely over the internet.

  :::{seealso}

  - <https://epics-controls.org/about-epics/>

  :::

**EPNix**
  EPNix is an EPICS environment build on top of Nix.
  I.e. it packages EPICS-related software using the Nix package manager.

  It enables you to build, package, deploy IOCs and other EPICS-related software
  (such as procServ, Phoebus, Archiver Appliance, etc).

  :::{seealso}

  - <https://epics-extensions.github.io/EPNix/>

  :::

**Top**
  An EPICS Top refers to the root of a directory (the "top" of the directory)
  — *and its associated structure (i.e. sub-directories architecture)* —
  where you can actually perform EPICS-specific development.
  You can find a lot of Top examples in the EPICS
  [modules](https://docs.epics-controls.org/en/latest/software/modules.html),
  e.g.:
  the [autosave (`v5.7.1`) Top](https://epics.anl.gov/bcda/synApps/autosave/autosave.html).
  Each Top can be maintained separately,
  one Top can "import" another one,
  and different Top can depend on different releases of external software
  (e.g. a Top can depend on EPICS `v3.14.12` and on autosave `v5.0.0`,
  while another Top can depend on EPICS `v7.0.6` and on autosave `v5.7.1`).

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/appdevguide/EPICSBuildFacility.html?highlight=top>.

  :::

**App**
  An EPICS App (also called IOC application)
  refers to a directory inside a Top
  (the name of that directory has to be suffixed with `App`).
  This is where you can effectively implement the logic of your EPICS application.
  For example: the `asApp` directory
  inside the [autosave Top](https://github.com/epics-modules/autosave).

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/appdevguide/gettingStarted.html?highlight=app#usage>.

  :::

**Sup**
  An EPICS Sup (also called support application)
  refers to another directory inside a Top
  (the name of that directory has to be suffixed with `Sup`).
  When compiling/building a Top,
  Sups are meant to be built before Apps,
  in order to be used by Apps.
  For example: the `devOpcuaSup` directory
  inside the [opcua Top](https://github.com/epics-modules/opcua/tree/master).

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/appdevguide/gettingStarted.html#building-ioc-components>

  :::

**IOC**
  Input/Output Controller. This is the I/O server component of EPICS.
  Almost any computing platform that can support EPICS basic components,
  like databases and network communication,
  can be used as an IOC.
  One example is a regular desktop computer,
  other examples are systems based on real-time operating systems
  (like vxWorks or RTEMS)
  and running on dedicated modular computing platforms
  (like MicroTCA, VME or CompactPCI).
  EPICS IOC can also run on low-cost hardware
  (like RaspberryPi or similar).

  Note that the IOC term is ambiguous,
  it can both design the hardware on which the EPICS I/O server is running,
  and the EPICS I/O server software itself
  (i.e. the development result of your EPICS Top).

  In order to clarify the IOC,
  it is possible to specifically refer to hardware IOC / IOC machine
  or to software IOC / IOC program.

  :::{warning}

  *Not to confused with SoftIOC*,
  which is undefined/unclear and may have a different meaning.

  See <https://epics.anl.gov/tech-talk/2012/msg02138.php>.

  :::

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/guides/EPICS_Intro.html>.

  :::

**Record**
  EPICS-based control system contains one or more IOC programs.
  Each IOC program loads one or more databases.
  A database is a collection of records of various types.

  A Record is an object with:

  - A unique name.
  - A behavior defined by its type.
  - Controllable properties (**fields**).
  - Optional associated hardware I/O (device support).
  - Links to other records.

  There are several different types of records available. For example:

  - The "analog input" and "analog output" (`ai` and `ao`) types,
    are used to store an analog value,
    and are typically used for things like temperatures, pressure, flow rates, etc.
  - The "binary input" and "binary output" (`bi` and `bo`) types,
    are used to store a boolean value,
    and are generally used for commands and statuses to and from equipment,
    i.e. for values like On/Off, Open/Closed and so on.
  - The "calc" and "calcout" records can access other records
    and perform a calculation based on their values.
    E.g. calculate the efficiency of a motor
    by a function of the current and voltage input and output,
    and converting to a percentage for the operator to read.

  Each record comprises a number of properties called fields.
  Fields can have different functions,
  typically they are used to configure how the record operates,
  or to store data items.

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/guides/EPICS_Process_Database_Concepts.html?highlight=PV#the-epics-process-database>
  - <https://docs.epics-controls.org/en/latest/appdevguide/databaseDefinition.html?highlight=record#record-record-instance>

  :::

**PV**
  A Process Variable is an "instantiated"/"implemented" record.
  I.e. once the IOC program is started,
  each previously defined record will have an associated PV running.
  A Record is just a blueprint for a PV.

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/specs/ca_protocol.html?highlight=Process%20Variable#process-variables>
  - <https://docs.epics-controls.org/en/latest/guides/EPICS_Process_Database_Concepts.html?highlight=Process%20Variable>
  - <https://docs.epics-controls.org/en/latest/guides/EPICS_Process_Database_Concepts.html?highlight=Process%20Variable#process-chains>

  :::

**Macro**
  A macro is a string substitution mechanism,
  that will allow some EPICS "configuration" files to be loaded
  after some strings have been replaced by others.
  E.g. `MY-MACRO-NAME=toto`, will replace every `${MY-MACRO-NAME}` by `toto`
  in any associated "configuration" file.
  This is very useful e.g. when loading the same "configuration" file multiple times
  but with some intended implementations differences.

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/appdevguide/databaseDefinition.html?highlight=macro#macro-substitution>

  :::

**Comment-Macro**
  A comment-macro is a particular way of using macros
  that allow to comment/uncomment parts of the
  associated "configuration" files.
  This is very handy, e.g. in order to set/unset some records or some fields
  when loading a "configuration" file.

  :::{seealso}

  - <https://epics.anl.gov/tech-talk/2019/msg01291.php>

  :::

**`.db` file**
  A DataBase file (`.db`) or record instance file,
  is an EPICS "configuration" file
  containing only record instances/implementations definitions.
  This file is like a list of records,
  which will details their associated types, names and fields.

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/appdevguide/databaseDefinition.html?highlight=database%20file#dbloadrecords>
  - <https://docs.epics-controls.org/en/latest/guides/EPICS_Process_Database_Concepts.html>
  - <https://docs.epics-controls.org/projects/how-tos/en/latest/applications/common-database-patterns.html>
  - <https://docs.epics-controls.org/projects/how-tos/en/latest/getting-started/creating-ioc.html?highlight=db#creation-of-an-input-output-controller-ioc>

  :::

**`.template` file**
  A Template file (`.template`) is just like a `.db` file,
  but also including macro(s).

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/appdevguide/databaseDefinition.html?highlight=template#example-7>
  - <https://docs.epics-controls.org/en/latest/specs/EPICSBuildFacility.html?highlight=template#templates>

  :::

**`.dbd` file**
  A DataBase Definition file is an EPICS "configuration" file
  containing any sort of definitions except for record instances/implementations
  (like found in the `.db` and `.template` files),
  because record instances/implementations are fundamentally different
  from the other definitions.

  A file containing record instances
  should never contain any of the other definitions and vice-versa.

  The definitions covered by a `.dbd` file include "Menus", "Record Types", "Devices",
  "Drivers", "Registrars", "Variables", "Functions", "Breakpoint Tables",
  "Record Instances"...

  :::{seealso}

  <https://docs.epics-controls.org/en/latest/appdevguide/databaseDefinition.html>

  :::

**`.substitutions` file**
  A `.substitutions` file is an EPICS "configuration" file
  that allows to load one or more `.template` files, multiple times.

  The syntax of a `.substitutions` file is covered in
  [this documentation](https://docs.epics-controls.org/en/latest/appdevguide/databaseDefinition.html?highlight=template#template-file-syntax)
  and the format of a `.substitutions` file is covered in
  [this documentation](https://docs.epics-controls.org/en/latest/appdevguide/databaseDefinition.html?highlight=template#template-file-formats).

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/appdevguide/databaseDefinition.html?highlight=template#dbloadtemplate>

  :::

**`.cmd` file**
  A `.cmd` file is an EPICS executable file
  that starts with a [Shebang](https://en.wikipedia.org/wiki/Shebang_(Unix))
  instructing the program loader to run the associated IOC program,
  passing the content of the `.cmd` file as the first argument.

  This `.cmd` file is mostly used to run the IOC program
  after loading all the associated EPICS "configuration" files
  (e.g. `.dbd`, `.db`, `.template`, `.substitutions`, etc).

  :::{seealso}

  <https://docs.epics-controls.org/en/latest/appdevguide/gettingStarted.html?highlight=cmd#run-the-ioc-example>

  :::

**`iocBoot` directory**
  TODO

**`bin` directory**
  TODO

**`lib` directory**
  TODO

**`db` directory**
  TODO

**`dbd` directory**
  TODO

**`configure` directory**
  TODO

**IOC Shell**

  Also called `iocsh`.

  The IOC Shell describes both the EPICS terminal shell which is launched
  after running an IOC programm,
  and the EPICS script language used to interact with that terminal shell
  (which is also used in the `.cmd` file).

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/appdevguide/gettingStarted.html?highlight=iocsh#chap:IOCShell>
  - <https://docs.epics-controls.org/en/latest/appdevguide/gettingStarted.html?highlight=cmd#run-the-ioc-example>

  :::

**CA**
  Channel Access (CA) is the default communication protocol
  used between EPICS servers (i.e. IOCs)
  and EPICS clients
  (i.e. HMI monitoring tools, archiving softwares, alarms systems, etc).
  It is mostly used to share PVs information across a network.
  CA will use UDP to initiate a client-server communication,
  and then use TCP for the rest of the communication.

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/specs/ca_protocol.html>
  - <https://epics.anl.gov/base/R7-0/6-docs/CAref.html>

  :::

**PVA**
  TODO

::::

