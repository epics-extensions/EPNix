{ lib
, epnixLib
, mkEpicsPackage
, fetchgit
, fetchpatch
, version ? "7.0.6"
, sha256 ? ""
, readline
, local_config_site ? { }
, local_release ? { }
}:

with lib;

let
  versions = lib.importJSON ./versions.json;
  hash = if sha256 != "" then sha256 else versions.${version}.sha256;

  atLeast = versionAtLeast version;
  older = versionOlder version;
in
mkEpicsPackage {
  pname = "epics-base";
  inherit version;
  varname = "EPICS_BASE";

  inherit local_config_site local_release;

  isEpicsBase = true;

  src = fetchgit {
    url = "https://git.launchpad.net/epics-base";
    rev = "R${version}";
    sha256 = hash;
  };

  patches = (optionals (older "7.0.5") [
    # Support "undefine MYVAR" in convertRelease.pl
    # Fixed by commit 79d7ac931502e1c25b247a43b7c4454353ac13a6
    ./handle-make-undefine-variable.patch
  ]) ++ (optionals (older "3.15.8") [
    # Needed to support "undefine MYVAR" in convertRelease.pl
    (fetchpatch {
      url = "https://git.launchpad.net/epics-base/patch/?id=961dd2bc5de9f197d7df3b8d23487b4a99df33c9";
      sha256 = "sha256-Tlmij9OO6SdrgbC629wZ/N8XW4DlOrQLHG8W1Bkq+3I=";
    })
  ]) ++ (optionals (older "3.15.5") [
    # This test doesn't work with Clang, due to array size too big
    # Fixed by commit 8da6c172d1564bb13b657ce2c671eaabebcefc98
    ./disable-libcom-epics-exception-test.patch

    # Fixes comment typo
    (fetchpatch {
      url = "https://git.launchpad.net/epics-base/patch/?id=89c8c78564d1dd56af647876ad1d217e08e040e7";
      sha256 = "sha256-cf3XbTaJxMoUeQuMD9WMu7XwzhbESf6UbwIPqSW+M1c=";
      includes = [ "configure/os/CONFIG_SITE.linux-x86_64.UnixCommon" ];
    })

    # Include CONFIG_SITE.local and RELEASE.local in template.
    #
    # The template is used in multiple places in mkEpnixDistribution (i.e.
    # eregen and top-source)
    #
    # Fixed by commit aa6e976f92d144b5143cf267d8b2781d3ec8b62b
    # rebased version:
    ./add-local-includes-to-makeBaseApp-templates.patch
  ]);

  propagatedBuildInputs = optional (older "7.0.0") readline;

  # EPICS_HOST_ARCH uses "$(CONFIG)/../startup/EpicsHostArch.pl", but the
  # "startup" directory is not installed.
  #
  # Fixed by commit 220e404203e51624fb7e90f8fe5bcde2ba2767c4
  postInstall = optionalString (older "3.15.6" || (atLeast "7.0.0" && older "7.0.2")) ''
    cp -r startup $out
  '';

  # TODO: find a way to "symlink" what is in ./bin/linux-x86_64 -> ./bin
  meta = {
    description = "The Experimental Physics and Industrial Control System";
    homepage = "https://epics-controls.org/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
