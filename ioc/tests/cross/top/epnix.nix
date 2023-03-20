{pkgs, ...}: {
  epnix = {
    meta.name = "cross-check";
    buildConfig.src = ./.;

    applications.apps = [./simpleApp];
  };
}
