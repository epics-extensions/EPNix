{
  config,
  epnixLib,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.dbwr;

  # An XSLT file to transform the `/var/tomcat/conf/context.xml` file,
  # to add our parameters.
  transformContext = pkgs.writeText "dbwr-transform-context.xslt" ''
    <xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    	<xsl:output method="xml" />
        <!-- Identity template, copies everything as is -->
        <xsl:template match="@*|node()">
          <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
          </xsl:copy>
        </xsl:template>
        <!-- Override for the <Context> block -->
        <xsl:template match="Context">
          <!-- Copy the element -->
          <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>

            <!-- And append our elements -->
            <xsl:comment> Configuration added by the DBWR EPNix NixOS module </xsl:comment>
            <Parameter
              name="org.apache.tomcat.websocket.textBufferSize"
              value="${toString cfg.websocketBufferSize}" />

          </xsl:copy>
        </xsl:template>
    </xsl:stylesheet>
  '';

  xsltproc = "${lib.getBin pkgs.libxslt}/bin/xsltproc";
  xmllint = "${lib.getBin pkgs.libxml2}/bin/xmllint";
in
{
  options.services.dbwr = {
    enable = lib.mkEnableOption "DBWR, the display builder web runtime";

    package = lib.mkPackageOption pkgs "DBWR" {
      default = [
        "epnix"
        "dbwr"
      ];
    };

    pvwsPackage = lib.mkPackageOption pkgs "PVWS" {
      default = [
        "epnix"
        "pvws"
      ];
    };

    openFirewall = lib.mkOption {
      description = ''
        Open the firewall for the DBWR service.

        :::{warning}
        This opens the firewall on all network interfaces.
        :::
      '';
      type = lib.types.bool;
      default = false;
    };

    websocketBufferSize = lib.mkOption {
      description = ''
        Maximum size of websocket buffers, in bytes.

        This value can be increased
        in the case the maximum message size is hit
        when subscribing to a large number of PVs.
      '';
      type = lib.types.int;
      default = 8192;
      example = 131072;
    };

    settings = lib.mkOption {
      description = ''
        Configuration for DBWR.

        These options will be passed as environment variables.
      '';
      default = { };
      type = lib.types.submodule {
        freeformType =
          with lib.types;
          attrsOf (oneOf [
            str
            path
          ]);
        options = {
          EPICS_CA_ADDR_LIST = lib.mkOption {
            description = ''
              List of Channel Access destination IP addresses.

              Each IP address can be a unicast address,
              or a broadcast address.

              Use `lib.mkForce` to override values from {nix:option}`environment.epics.ca_addr_list`.
            '';
            type = with lib.types; listOf str;
            defaultText = lib.literalExpression ''
              if config.environment.epics.enable
              then config.environment.epics.ca_addr_list
              else [];
            '';
            # Separated by spaces
            apply = toString;
          };

          EPICS_CA_AUTO_ADDR_LIST = lib.mkOption {
            description = ''
              If set,
              behave as if every broadcast address of every network interface is added to `EPICS_CA_ADDR_LIST`.

              Use `lib.mkForce` to override values from {nix:option}`environment.epics.ca_auto_addr_list`.
            '';
            type = lib.types.bool;
            defaultText = lib.literalExpression ''
              if config.environment.epics.enable
              then config.environment.epics.ca_auto_addr_list
              else [];
            '';
            apply = b: if b then "YES" else "NO";
          };

          PV_DEFAULT_TYPE = lib.mkOption {
            description = "Default PV type.";
            type = lib.types.str;
            default = "ca";
            example = "pva";
          };

          PV_WRITE_SUPPORT = lib.mkOption {
            description = "Whether to enable PV write support.";
            type = lib.types.bool;
            default = false;
            example = true;
            apply = lib.boolToString;
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.dbwr.settings = {
      CATALINA_OUT_CMD = "cat";
      EPICS_CA_ADDR_LIST =
        if config.environment.epics.enable then config.environment.epics.ca_addr_list else [ ];
      EPICS_CA_AUTO_ADDR_LIST =
        if config.environment.epics.enable then config.environment.epics.ca_auto_addr_list else true;
    };

    services.tomcat = {
      enable = true;

      # See comment in archiver-appliance.nix
      purifyOnStart = true;

      webapps = [
        cfg.pvwsPackage
        cfg.package
      ];
    };

    systemd.services.tomcat = {
      environment = cfg.settings;
      preStart = ''
        # Apply DBWR transformations to context.xml
        ${xsltproc} ${transformContext} /var/tomcat/conf/context.xml | \
          ${xmllint} --format - > /var/tomcat/conf/context.xml.new
        mv /var/tomcat/conf/context.xml.new /var/tomcat/conf/context.xml
      '';
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ 8080 ];
  };

  meta.maintainers = with epnixLib.maintainers; [ minijackson ];
}
