{
  services.archiver-appliance = {
    enable = true;
    stores.lts.location = "/srv/lts";
    stores.mts.location = "/srv/mts";

    openFirewall = true;
  };

  services.tomcat.javaOpts = "-Xmx256m";
}
