{
  lib,
  epnix,
  epnixLib,
}:
(epnix.mkLewisSimulator {
  name = "psu_simulator";
  package = "psu_simulator";
  source = ./.;
})
// {
  pname = "psu_simulator";
  version = "0.2.0";

  meta = {
    description = "A power supply simulator for the StreamDevice tutorial";
    homepage = "https://epics-extensions.github.io/EPNix/ioc/tutorials/streamdevice.html";
    license = lib.licenses.asl20;
    maintainers = with epnixLib.maintainers; [minijackson];
  };
}
