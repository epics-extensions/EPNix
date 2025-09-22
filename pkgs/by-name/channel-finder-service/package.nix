{
  lib,
  epnixLib,
  fetchFromGitHub,
  jdk21,
  maven,
  makeWrapper,
}:
maven.buildMavenPackage rec {
  pname = "ChannelFinderService";
  version = "4.7.2";

  src = fetchFromGitHub {
    owner = "ChannelFinder";
    repo = pname;
    rev = "refs/tags/ChannelFinder-${version}";
    hash = "sha256-mRZ9lnkSMSW07GjihDJUDsQFE/f0Sn4T1WbwpUTY16Y=";
  };

  patches = [ ./fix-reproducibility.patch ];

  mvnJdk = jdk21;
  mvnHash = "sha256-R5lsFM+yn9xc3Wbpy9Js5r9d7IEOJR301mEoz5SGI/0=";
  # TODO: remove if this PR is merged:
  # https://github.com/ChannelFinder/ChannelFinderService/pull/153
  mvnParameters = "-Dproject.build.outputTimestamp=1980-01-01T00:00:02Z";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/java

    jarName="ChannelFinder-${version}.jar"

    install -Dm644 "target/$jarName" "$out/share/java"

    makeWrapper ${lib.getExe jdk21} $out/bin/${meta.mainProgram} \
      --add-flags "-jar $out/share/java/$jarName"

    runHook postInstall
  '';

  meta = {
    description = "A RESTful directory services for a list channels";
    homepage = "https://channelfinder.readthedocs.io/en/latest/";
    mainProgram = "channel-finder-service";
    license = lib.licenses.mit;
    maintainers = with epnixLib.maintainers; [ minijackson ];
    inherit (jdk21.meta) platforms;
  };
}
