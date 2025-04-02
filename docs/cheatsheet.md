# Cheatsheet

See the {doc}`../ioc/tutorials/pre-requisites`
and the {doc}`../ioc/user-guides/flake-registry` guide
before getting started.

## IOCs

For an introduction into IOC development,
read {doc}`../ioc/tutorials/streamdevice`.

### IOC creation

```{list-table}
:width: 100%
:widths: 2, 3

* - ```bash
    nix flake new -t epnix myTop
    ```
  - Create an EPNix EPICS top
* - ```bash
    makeBaseApp.pl -t ioc name
    ```
  - Initialize an EPICS app in an EPICS top
* - ```bash
    makeBaseApp.pl -a linux-x86_64 -i -t ioc -p name Name
    ```
  - Initialize an `iocBoot` folder in an EPICS top
```

### IOC development

```{list-table}
:width: 100%
:widths: 2, 3

* - ```nix
    propagatedBuildInputs = [
      epnix.support.StreamDevice
    ];
    ```
  - In {file}`ioc.nix`, add an EPICS support module to the build environment
* - ```nix
    nativeBuildInputs = [myLib];
    buildInputs = [myLib];
    ```
  - In {file}`ioc.nix`, add a native library to the build environment
* - ```make
    myApp_DBD = stream.dbd
    myApp_LIBS = stream
    ```
  - In {file}`myApp/src/Makefile`,
    add an EPICS support module to an EPICS app
```

### Important files

See {doc}`../ioc/explanations/template-files` for more detailed information.

```{list-table}
:width: 100%
:widths: 2, 3

* - {file}`flake.nix`
  - Nix project file
* - {file}`ioc.nix`
  - Defines the EPICS top build
* - {file}`checks/simple.nix`
  - Defines the ``simple`` integration check
```

### IOC building

```{list-table}
:width: 100%
:widths: 2, 3

* - ```bash
    nix build -L
    ```
  - Build the IOC, showing compilation logs
* - ```bash
    nix develop
    ```
  - Enter the development shell
* - ```bash
    epicsConfigurePhase
    ```
  - *In the development shell,* configure the EPICS build
* - ```bash
    make
    ```
  - *In the development shell,* manually build the EPICS top
```

### Flake input overrides

```{list-table}
:width: 100%
:widths: 2, 3

* - ```bash
    nix build -L \
      --override-input \
      supportModule \
      /path/to/supportModule
    ```
  - Build the IOC, but with a custom version of a support module
* - ```bash
    nix develop \
      --override-input \
      supportModule \
      /path/to/supportModule
    ```
  - Enter the development shell, but with a custom version of a support module
```

### IOC testing

```{list-table}
:width: 100%
:widths: 2, 3

* - ```bash
    nix flake check -L
    ```
  - Run IOC checks
* - {doc}`../ioc/tutorials/integration-tests`
  - IOC testing tutorial documentation
* - {doc}`../ioc/user-guides/testing/index`
  - IOC testing guides
```

### IOC inspection

For IOCs deployed on NixOS system
by using the {doc}`../nixos-services/user-guides/ioc-services` options.

```{list-table}
:width: 100%
:widths: 2, 3

* - ```bash
    systemctl status myIoc
    ```
  - Check whether an IOC is running
* - ```bash
    systemctl restart myIoc
    ```
  - Restart an IOC
* - ```bash
    systemctl stop myIoc
    ```
  - Stop an IOC
* - ```bash
    journalctl -xefu myIoc
    ```
  - Follow the logs of an IOC
* - ```bash
    telnet-myIoc
    ```
  - Connect to the command-line of an IOC
```

## NixOS services

For an introduction into how to deploy EPICS-related services,
read the {doc}`../nixos-services/tutorials/archiver-appliance` tutorial.

### Applying NixOS changes

```{list-table}
:width: 100%
:widths: 2, 3

* - ```bash
    nixos-rebuild test
    ```
  - Apply changes now, but revert them on reboot
* - ```bash
    nixos-rebuild switch
    ```
  - Apply changes now, and keep them on reboot
* - ```bash
    nixos-rebuild boot
    ```
  - Apply changes for the next reboot
```
