{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.tomcat;
  convertTomcat9WebApp =
    webapp:
    pkgs.runCommand "${webapp.name}-jakartaee"
      {
        nativeBuildInputs = [ pkgs.epnix.tomcat-jakartaee-migration ];
      }
      ''
        shopt -s nullglob extglob

        mkdir -p $out
        cp -a ${webapp}/!(webapps) $out

        for war in ${webapp}/webapps/*.war; do
          filename=$(basename "$war")
          tomcat-jakartaee-migration "$war" "$out/webapps/$filename"
        done
      '';
in
{
  options.services.tomcat.tomcat9webapps = lib.mkOption {
    description = ''
      List containing Java EE 8 (Tomcat9) WAR files or directories with WAR files which are web applications to be deployed on Tomcat.

      These webapps will be converted to a JakartaEE-compatible version
      by using the `tomcat-jakartaee-migration` utility.
    '';
    type = with lib.types; listOf path;
    default = [ ];
  };

  config.services.tomcat.webapps =
    if lib.versionAtLeast cfg.package.version "10" then
      map convertTomcat9WebApp cfg.tomcat9webapps
    else
      cfg.tomcat9webapps;
}
