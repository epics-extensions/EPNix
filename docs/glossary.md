# Glossary

::::{glossary}
Nix
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

  For more information about the pros and cons of using Nix,
  see the {doc}`advantages-disadvantages` page.
  Nix is is also the name of the programming language used by the package manager.

  :::{seealso}

  - <https://wiki.nixos.org/wiki/Nix_(package_manager)>
  - <https://wiki.nixos.org/wiki/Nix_(language)>
  - <https://wiki.nixos.org/wiki/Nix_ecosystem>

  :::

NixOS
  NixOS is a Linux distribution based on the Nix package manager and build system.
  All components of this distribution --- including the kernel,
  installed packages and system configuration files ---
  are built by Nix from "pure functions" called Nix expressions.

  :::{seealso}

  - <https://wiki.nixos.org/wiki/NixOS>
  - <https://wiki.nixos.org/wiki/Nix_ecosystem>
  - <https://nixos.org/>

  :::

Nixpkgs
  Nixpkgs claims to be the largest repository of Nix packages and NixOS modules.
  The repository is hosted on GitHub and maintained by the community,
  with official backing from the NixOS Foundation.

  Those packages are usable by any Linux distribution.

  :::{seealso}

  - <https://wiki.nixos.org/wiki/Nixpkgs>
  - <https://wiki.nixos.org/wiki/Nix_ecosystem>

  :::

EPICS
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

EPNix
  EPNix is an EPICS environment build on top of Nix.
  I.e. it packages EPICS-related software using the Nix package manager.

  It enables you to build, package, deploy IOCs and other EPICS-related software
  (such as procServ, Phoebus, Archiver Appliance, etc).

  :::{seealso}

  - <https://epics-extensions.github.io/EPNix/>

  :::

IOC
  Input/Output Controller. This is the I/O server component of EPICS.

  The task of an IOC controlling an industrial equipment
  is to relay and process information
  between the equipment
  and other EPICS-compatible applications.
  For example,
  when an operator sends a command through EPICS,
  the IOC is tasked with relaying that command
  to the hardware.
  When the hardware reports a measurement,
  the IOC parses the measurement from the hardware,
  convert it to a human readable value,
  and transmits it to other EPICS applications.

  An IOC can also exists
  without any industrial equipment to control,
  and typically provide its own logic
  for controlling other aspects of a control system.
  Note that the IOC term is ambiguous,
  it can both design the hardware on which the EPICS I/O server is running,
  and the EPICS I/O server software itself
  (i.e. the EPICS-specific development result).

  In order to clarify the IOC,
  it is possible to specifically refer to hardware IOC / IOC machine
  or to software IOC / IOC program.

  :::{warning}

  In the EPNix documentation,
  if not specified/clarified,
  the term "IOC" will always refer to software IOC / IOC program.

  *Not to confused with SoftIOC*,
  which is undefined/unclear and may have a different meaning.

  See <https://epics.anl.gov/tech-talk/2012/msg02138.php>.
  :::

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/guides/EPICS_Intro.html>.

  :::

Top
  An EPICS Top refers to the root of a directory (the "top" of the directory)
  --- *and its associated structure (i.e. sub-directories architecture)* ---
  where you can actually perform EPICS-specific development.
  You can find a lot of Top examples in the EPICS
  [modules](https://docs.epics-controls.org/en/latest/software/epics-related-software.html),
  e.g.:
  the [autosave Top](https://epics.anl.gov/bcda/synApps/autosave/autosave.html).
  Each Top can be maintained separately,
  one Top can "import" another one,
  and different Top can depend on different releases of external software
  (e.g. a Top can depend on EPICS `v3.14.12` and on autosave `v5.0.0`,
  while another Top can depend on EPICS `v7.0.6` and on autosave `v5.7.1`).

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/appdevguide/EPICSBuildFacility.html?highlight=top>.

  :::

App
  An EPICS App (also called IOC application)
  refers to a directory inside a Top
  (the name of that directory has to be suffixed with `App`).
  This is where you can effectively implement the logic of your EPICS application.
  For example: the `asApp` directory
  inside the [autosave Top](https://github.com/epics-modules/autosave).
  This folder is created by the `makeBaseApp.pl` EPICS command
  and contains by default two sub-directories:

  - The `Db` sub-directory,
    containing --- among other things --- the "database" declaration of your application
    (see `.db` file bellow);
  - The `src` sub-directory,
    containing the source code of your application.

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/appdevguide/gettingStarted.html?highlight=app#usage>.

  :::

Sup
  An EPICS Sup (also called support application)
  refers to another directory inside a Top
  (the name of that directory has to be suffixed with `Sup`).
  When compiling/building a Top,
  Sups are functionally the same as Apps,
  but they are meant to be built before,
  in order to be used by Apps.
  For example: the `devOpcuaSup` directory
  inside the [opcua Top](https://github.com/epics-modules/opcua/tree/master).

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/appdevguide/gettingStarted.html#building-ioc-components>

  :::

Record
  Records are the building blocks of EPICS IOCs.
  They usually correspond to a controllable parameter of some hardware.

  EPICS-based control system contains one or more IOC.
  Each IOC loads one or more databases.
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

  - <https://docs.epics-controls.org/en/latest/process-database/EPICS_Process_Database_Concepts.html?highlight=PV#the-epics-process-database>
  - <https://docs.epics-controls.org/en/latest/appdevguide/databaseDefinition.html?highlight=record#record-record-instance>

  :::

PV
  A Process Variable is a value or variable accessible through EPICS communication protocols
  (Channel Access and PV Access).
  You can address this value using its unique PV name.

  A Process Variable is a field from a record:

  ```
  PV = record_name + "." + field_name
  ```

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/internal/ca_protocol.html?highlight=Process%20Variable#process-variables>
  - <https://docs.epics-controls.org/en/latest/process-database/EPICS_Process_Database_Concepts.html?highlight=Process%20Variable>
  - <https://docs.epics-controls.org/en/latest/process-database/EPICS_Process_Database_Concepts.html?highlight=Process%20Variable#process-chains>

  :::

Macro
  A macro is a string substitution mechanism,
  that allows some EPICS "configuration" files to be loaded
  after some strings have been replaced by others.
  E.g. `MY_MACRO_NAME=toto`, will replace every `${MY_MACRO_NAME}` by `toto`
  in any associated "configuration" file.
  This is very useful e.g. when loading the same "configuration" file multiple times
  but with some intended implementations differences.

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/appdevguide/databaseDefinition.html?highlight=macro#macro-substitution>

  :::

Comment-Macro
  A comment-macro is a particular way of using macros
  that allow to comment/uncomment parts of the
  associated "configuration" files.
  This is very handy, e.g. in order to set/unset some records or some fields
  when loading a "configuration" file.

  :::{seealso}

  - <https://epics.anl.gov/tech-talk/2019/msg01291.php>

  :::

`.db` file
  A DataBase file (`.db`) or record instance file,
  is an EPICS "configuration" file
  containing only record definitions.
  This file is like a list of records,
  which will details their associated types, names and fields.

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/appdevguide/databaseDefinition.html?highlight=database%20file#dbloadrecords>
  - <https://docs.epics-controls.org/en/latest/process-database/EPICS_Process_Database_Concepts.html>
  - <https://docs.epics-controls.org/en/latest/process-database/common-database-patterns.html>
  - <https://docs.epics-controls.org/en/latest/getting-started/creating-ioc.html?highlight=db>

  :::

`.template` file
  A Template file (`.template`) is just like a `.db` file,
  but have macros that needs to be replaced,
  usually with a `.substitutions` file.

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/appdevguide/databaseDefinition.html?highlight=template#example-7>
  - <https://docs.epics-controls.org/en/latest/build-system/specifications.html?highlight=template#templates>

  :::

`.dbd` file
  A DataBase Definition file is an EPICS "configuration" file
  containing any sort of definitions except for record definitions
  (like found in the `.db` and `.template` files).

  A file containing record instances
  should never contain any of the other definitions and vice-versa.

  The definitions covered by a `.dbd` file include "Menus", "Record Types", "Devices",
  "Drivers", "Registrars", "Variables", "Functions", "Breakpoint Tables",
  "Record Instances"...

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/appdevguide/databaseDefinition.html>

  :::

`.substitutions` file
  A `.substitutions` file is an EPICS "configuration" file
  that allows to load one or more `.template` files, multiple times.

  See the [template file syntax documentation](https://docs.epics-controls.org/en/latest/appdevguide/databaseDefinition.html?highlight=template#template-file-syntax)
  and the [template file format documentation](https://docs.epics-controls.org/en/latest/appdevguide/databaseDefinition.html?highlight=template#template-file-formats)
  of a `.substitutions` file.

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/appdevguide/databaseDefinition.html?highlight=template#dbloadtemplate>

  :::

`.cmd` file
  The `.cmd` file is mostly used to run the IOC
  and to load all the associated EPICS "configuration" files
  (e.g. `.dbd`, `.db`, `.template`, `.substitutions`, etc).

  A `.cmd` file is an EPICS executable file
  that starts with a [Shebang](https://en.wikipedia.org/wiki/Shebang_(Unix))
  instructing the program loader to run the associated IOC,
  passing the content of the `.cmd` file as the first argument.

  :::{seealso}

  <https://docs.epics-controls.org/en/latest/appdevguide/gettingStarted.html?highlight=cmd#run-the-ioc-example>

  :::

IOC Shell

  Also called `iocsh`.

  The IOC Shell describes both the EPICS terminal shell which is launched
  after running an IOC,
  and the EPICS script language used to interact with that terminal shell
  (which is also used in the `.cmd` file).

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/appdevguide/gettingStarted.html?highlight=cmd#run-the-ioc-example>

  :::

`iocBoot` directory
  This directory is created into your Top after running the `makeBaseApp.pl` EPICS command.

  You'll find this directory at the root of your Top (and in the `result` directory if using EPNix).

  It contains sub-directories,
  usually one per App,
  with a name starting with `ioc` (e.g. `iocMyIOC`).
  Each sub-dir is associated to a specific App through the `makeBaseApp.pl` EPICS command.

  Inside the sub-directories, you'll find the `.cmd` file allowing to start the IOC.
  You'll also find the `envPaths` file,
  created after building the Top,
  which contains some environment variables to be loaded at the start of the `.cmd`.

`bin` directory
  This directory is created into your Top after building it,
  either with `make` or with `nix build` if using EPNix.

  You'll find this directory at the root of your Top or in the `result` directory if using EPNix.

  The binary executable file(s) will end up there.
  This binary is call from the [Shebang](https://en.wikipedia.org/wiki/Shebang_(Unix))
  at the very start of the `.cmd` file,
  allowing to "run" your IOC.

`lib` directory
  This directory is created into your Top after building it,
  either with `make` or with `nix build` if using EPNix.

  You'll find this directory at the root of your Top or in the `result` directory if using EPNix.

  The library file(s) will end up there.

`db` directory
  This directory is created into your Top after building it,
  either with `make` or with `nix build` if using EPNix.

  You'll find this directory at the root of your Top or in the `result` directory if using EPNix.

  All the `.db` files will end up being copied there,
  allowing to find them with more ease
  (e.g. at runtime from the `.cmd` file, or from the IOC Shell).

`dbd` directory

  This directory is created into your Top after building it,
  either with `make` or with `nix build` if using EPNix.

  You'll find this directory at the root of your Top or in the `result` directory if using EPNix.

  All the `.dbd` files will end up being copied there,
  allowing to find them with more ease
  (e.g. at runtime from the `.cmd` file, or from the IOC Shell).

`configure` directory
  This directory is created into your Top after running the `makeBaseApp.pl` EPICS command.

  You'll find this directory at the root of your Top (and in the `result` directory if using EPNix).

  It might contains some of the bellow configuration files:

  - `CONFIG`: EPICS configuration file for builds;
  - `CONFIG_SITE`: EPICS configuration file for application-specific builds;
  - `CONFIG_SITE.local`: EPICS configuration file allowing to override CONFIG_SITE without having to modify it;
  - `RELEASE`: EPICS configuration file for base and external support modules location;
  - `RELEASE.local`: EPICS configuration file allowing to override RELEASE without having to modify it;
  - `RULES`: EPICS configuration file including the appropriate rules configuration file;
  - `RULES.ioc`: EPICS build configuration file of the iocBoot/ sub-directorie(s);
  - `RULES_DIRS`: EPICS build configuration file of each subdirectory;
  - `RULES_TOP`: EPICS configuration file specific to a Top.

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/build-system/specifications.html#configuration-files>

  :::

CA
  Channel Access (CA) is the default communication protocol
  used between EPICS servers (i.e. IOCs)
  and EPICS clients
  (i.e. HMI monitoring tools, archiving softwares, alarms systems, etc).
  It is mostly used to share PVs information across a network.
  CA will *optionally* use UDP to initiate a client-server communication,
  and then use TCP for the rest of the communication.

  :::{seealso}

  - <https://docs.epics-controls.org/en/latest/specs/ca_protocol.html>
  - <https://epics.anl.gov/base/R7-0/6-docs/CAref.html>

  :::

PVA
  PV Access (PVA) is the "new" communication protocol
  used between EPICS servers (i.e. IOCs)
  and EPICS clients
  (i.e. HMI monitoring tools, archiving softwares, alarms systems, etc).
  It is mostly used to share PVs information across a network (like CA),
  but it also encompasses a structured data encoding referred to as PV Data.

  :::{seealso}

  - <https://epics-controls.org/resources-and-support/documents/pvaccess/>
  - <https://github.com/epics-base/pvAccessCPP/wiki/protocol>
  - <https://docs.epics-controls.org/en/latest/pv-access/overview.html>

  :::

::::
