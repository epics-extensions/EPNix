Creating a StreamDevice IOC
===========================

In this tutorial,
you’re going to learn how to create an EPICS IOC with EPNix
that communicates with a power supply,
using the `StreamDevice`_ support module.

.. _StreamDevice: https://paulscherrerinstitute.github.io/StreamDevice/

Pre-requisites
--------------

Verify that you have all pre-requisites installed.
If not,
follow the :doc:`./pre-requisites` section.

Running the power supply simulator
----------------------------------

EPNix has a power supply simulator
for you to test your IOC.

To run it:

.. code-block:: bash

   nix run 'github:epics-extensions/epnix#psu-simulator'

For the rest of the tutorial,
leave it running in a separate terminal.

Creating your top
-----------------

We can use these command to create an EPNix top:

.. code-block:: bash

   # Initialise an EPNix top
   nix flake new -t 'github:epics-extensions/epnix' my-top
   cd my-top

   # Enter the EPNix development shell, that has EPICS base installed in it.
   nix develop

   # Create your app and ioc boot folder
   makeBaseApp.pl -t ioc example
   makeBaseApp.pl -i -t ioc -p example -a linux-x86_64 Example

   # Create a git repository, and make sure all files are tracked
   git init
   git add .

After that,
you can already check that your top build with:

.. code-block:: bash

   nix build -L

This ``nix build`` command compiles your IOC,
and all its dependencies.
This makes the usual EPICS environment setup unneeded.

If found in the official Nix cache server,
Nix downloads packages from there
instead of compiling them.

This command puts a ``./result`` symbolic link in your current directory,
containing the compilation result.

Adding StreamDevice to the EPNix environment
--------------------------------------------

Adding dependencies to the EPNix environment happen inside the ``flake.nix`` file.
This file is the main entry point for specifying your build environment:
most Nix commands used here read this file to work.

For adding StreamDevice,
change yours like so:

.. code-block:: diff
   :caption: :file:`flake.nix`

            # Add one of the supported modules here:
            # ---
   -        #support.modules = with pkgs.epnix.support; [ StreamDevice mySupportModule ];
   +        support.modules = with pkgs.epnix.support; [ StreamDevice ];

Then,
leave your EPNix development shell by running ``exit``,
and re-enter it with ``nix develop``.

Because you modified the support modules,
run ``eregen-config`` to regenerate ``configure/RELEASE.local``.

With this,
your development shell has StreamDevice available,
and StreamDevice is also added in the ``RELEASE.local`` file.

.. tip::

   As a rule,
   each time you edit the ``flake.nix`` file,
   leave and re-enter your development shell (``exit`` then ``nix develop``),
   and run ``eregen-config``.

Adding StreamDevice to your EPICS app
-------------------------------------

To add StreamDevice to your app,
make the following modifications:

Change the ``exampleApp/src/Makefile``
so that your App knows the record types of StreamDevice and its dependencies.
Also change that file so that it links to the StreamDevice library and its dependencies,
during compilation.
For example:

.. code-block:: makefile
   :caption: :file:`exampleApp/src/Makefile`

   # ...

   # Include dbd files from all support applications:
   example_DBD += calc.dbd
   example_DBD += asyn.dbd
   example_DBD += stream.dbd
   example_DBD += drvAsynIPPort.dbd

   # Add all the support libraries needed by this IOC
   example_LIBS += calc
   example_LIBS += asyn
   example_LIBS += stream

   # ...

Create the ``exampleApp/Db/example.proto`` file
that has the definition of the protocol.
This file tells StreamDevice what to send the power supply,
and what to expect in return.

.. code-block:: perl
   :caption: :file:`exampleApp/Db/example.proto`

   Terminator = LF;

   getVoltage {
       out ":volt?"; in "%f";
   }

   setVoltage {
       out ":volt %f";
       @init { getVoltage; }
   }

Create the ``exampleApp/Db/example.db`` file.
That file specifies the name, type, and properties of the Process Variables (PV)
that EPICS exposes over the network.
It also specifies how they relate to the functions written in the protocol file.

.. code-block:: perl
   :caption: :file:`exampleApp/Db/example.db`

   record(ai, "${PREFIX}VOLT-RB") {
       field(DTYP, "stream")
       field(INP, "@example.proto getVoltage ${PORT}")
   }

   record(ao, "${PREFIX}VOLT") {
       field(DTYP, "stream")
       field(OUT, "@example.proto setVoltage ${PORT}")
   }

Change ``exampleApp/Db/Makefile``
so that the EPICS build system installs ``example.proto`` and ``example.db``:

.. code-block:: makefile
   :caption: :file:`exampleApp/Db/Makefile`

   # ...

   #----------------------------------------------------
   # Create and install (or just install) into <top>/db
   # databases, templates, substitutions like this
   DB += example.db
   DB += example.proto

   # ...

Change your ``st.cmd`` file
so that it knows where to load the protocol file,
and how to connect to the remote power supply.

.. code-block:: csh
   :caption: :file:`iocBoot/iocExample/st.cmd`

   #!../../bin/linux-x86_64/example

   < envPaths

   ## Register all support components
   dbLoadDatabase("${TOP}/dbd/example.dbd")
   example_registerRecordDeviceDriver(pdbbase)

   # Where to find the protocol files
   epicsEnvSet("STREAM_PROTOCOL_PATH", "${TOP}/db")
   # The TCP/IP address of the power supply
   drvAsynIPPortConfigure("PS1", "localhost:9999")

   ## Load record instances
   dbLoadRecords("${TOP}/db/example.db", "PREFIX=, PORT=PS1")

   iocInit()

And run ``chmod +x iocBoot/iocExample/st.cmd``
so that you can run your command file as-is.

You can test that your top builds by running:

.. code-block:: bash

   nix build -L

You will see that your IOC does not build.
This is because we haven’t told Git to track those newly added files,
and so Nix ignores them too.

Run ``git add .`` for Git and Nix to track all files,
and try a ``nix build -L`` again.

If everything goes right,
you can examine your compiled top under ``./result``.

You can observe that:

-  the ``example`` app is installed under ``bin/`` and ``bin/linux-x86_64``,
   and links to the correct libraries
-  ``example.proto`` and ``example.db`` are installed under ``db/``
-  ``example.dbd`` is generated and installed under ``dbd/``

Running your IOC
----------------

To run your IOC,
build it first with ``nix build -L``,
and change directory into the ``./result/iocBoot/iocExample`` folder.
Then, run:

.. code-block:: bash

   ./st.cmd

You should see the IOC starting and connecting to ``localhost:9999``.

Recompiling with make
---------------------

Using ``nix build`` to compile your IOC each time might feel slow.
This is because Nix re-compiles your IOC from scratch each time.

If you want a more “traditional” edit / compile / run workflow,
you can place yourself in the development shell with ``nix develop``,
and use ``make`` from here.

Next steps
----------

More commands are available in the power supply simulator.
To view them,
close your IOC,
and open a direct connection to the simulator:

.. code-block:: bash

   nc localhost 9999
   # or
   telnet localhost 9999

You can install the ``nc`` command through the ``netcat`` package,
or you can install the ``telnet`` command through the ``telnet`` package,

Either command opens a prompt
where you can type ``help`` then press enter
to view the available commands.

Try to edit the protocol file and the database file
to add those features to your IOC.

For more information about how to write the StreamDevice protocol,
have a look at the `Protocol Files`_ documentation.

You might also be interested in reading :doc:`../user-guides/flake-registry`.

.. _Protocol Files: https://paulscherrerinstitute.github.io/StreamDevice/protocol.html

Pitfalls
--------

Although EPNix tries to be close to a standard EPICS development,
some differences might lead to confusion.
You can find more information about this in the :doc:`../faq`.
