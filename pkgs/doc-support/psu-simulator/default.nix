{
  poetry2nix,
  lib,
  epnixLib,
}:
poetry2nix.mkPoetryApplication {
  projectDir = ./.;

  meta = {
    homepage = "https://epics-extensions.github.io/EPNix/";
    license = lib.licenses.asl20;
    maintainers = with epnixLib.maintainers; [minijackson];
  };
}
