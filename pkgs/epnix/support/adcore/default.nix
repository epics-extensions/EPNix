{
  mkEpicsPackage,
  fetchFromGitHub,
  epnix,
  lib,
  epnixLib,
  libxml2,

  withHDF5 ? false,
  hdf5,
}:
mkEpicsPackage rec {
  pname = "adcore";
  version = "3-14";

  varname = "ADCORE";

  src = fetchFromGitHub {
    owner = "areaDetector";
    repo = pname;
    rev = "R${version}";
    hash = "sha256-il/mP6muwar5BclYTjUERy6LUyh3MUJZVkTxXzCecvA=";
  };

  propagatedBuildInputs = with epnix.support; [asyn libxml2];

  patches = lib.optional withHDF5 ./include-xmllib-global.patch;

  postPatch = ''
    echo "RELEASE_INCLUDES += -I${libxml2.dev}/include/libxml2" >> configure/RELEASE
    cat configure/RELEASE
  '' + lib.optionalString withHDF5 ''
    echo "WITH_HDF5=YES" >> configure/RELEASE
    echo "HDF5_EXTERNAL=YES" >> configure/RELEASE
    echo "HDF5_LIB=${hdf5}/lib" >> configure/RELEASE
  '';

  buildInputs = [libxml2] ++ lib.optional withHDF5 hdf5;

  meta = {
    description = "An asyn driver that creates parameters dynamically based on content of record links";
    homepage = "https://epics.cosylab.com/documentation/autoparamDriver/";
    license = lib.licenses.mit;
    maintainers = with epnixLib.maintainers; [synthetica];
  };
}
