{pkgs, ...}: {
  epnix = {
    meta.name = "checks-support-pvxs-standalone-server";
    buildConfig.src = ./.;

    support.modules = with pkgs.epnix.support; [pvxs];
  };
}
