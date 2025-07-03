{
  lib,
  epnix,
  epnixLib,
}:
# Use recursiveUpdate so that it doesn't override meta.mainProgram
lib.recursiveUpdate
(epnix.mkLewisSimulator {
  name = "psu-simulator";
  source = ./.;
  package = "psu_simulator";
  device = "psu_simulator";
})
{
  pname = "psu_simulator";
  version = "0.2.0";

  meta = {
    description = "A power supply simulator for the StreamDevice tutorial";
    homepage = "https://epics-extensions.github.io/EPNix/nixos-24.11/ioc/tutorials/streamdevice.html";
    license = lib.licenses.asl20;
    maintainers = with epnixLib.maintainers; [minijackson];
  };
}
