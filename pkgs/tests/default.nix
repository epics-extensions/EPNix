# For packages that are not directly exposed to the user,
# but should still work.
#
# For example kernel modules, which depend on the kernel version,
# or Python libraries, which depend on the Python version.
{pkgs, ...}: {
  channelfinder-default-python = pkgs.python3Packages.channelfinder;
  mrf-driver-default-linux = pkgs.linuxPackages.mrf;
  recceiver-default-python = pkgs.python3Packages.recceiver;
  aiaoca-default-python = pkgs.python3Packages.aioca;
}
