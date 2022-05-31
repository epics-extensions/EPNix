{
  stdenv,
  lib,
  fetchFromGitHub,
  autoreconfHook,
  epnixLib,
}:
stdenv.mkDerivation rec {
  pname = "procServ";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "ralphlange";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-MVifC4mq8tM71YpXFu0u0fGwq6vtbK/jofCJShjfq3Q=";
  };

  nativeBuildInputs = [autoreconfHook];

  # Can't figure out how to add latex packages for dblatex, so let's build it
  # without doc for now...
  configureFlags = ["--disable-doc"];

  meta = {
    description = "Wrapper to start arbitrary interactive commands in the background, with telnet or Unix domain socket access to stdin/stdout";
    homepage = "https://github.com/ralphlange/procServ";
    license = lib.licenses.gpl3Plus;
    maintainers = with epnixLib.maintainers; [minijackson];
  };
}
