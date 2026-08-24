{
  lib,
  stdenvNoCC,
  fetchurl,
  patchelf,
  bzip2,
  gnutar,
  pkgsi686Linux,
}:

let
  i686 = pkgsi686Linux;
in

stdenvNoCC.mkDerivation {
  pname = "checkpoint-snx";
  version = "800008409";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/sergey-belikov/snx-packaged/master/snx-800008409-800008409/bin/snx_install.sh";

    hash = "sha256-HjTsiI+6nyfHV2xL6stHpiIcbaVv/JdB8uUYGFX7WiU=";
  };

  nativeBuildInputs = [
    patchelf
    bzip2
    gnutar
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack

    cp "$src" snx_install.sh

    archiveOffset=$(
      awk -F= '
        /ARCHIVE_OFFSET/ {
          print $2
        }

        FNR == 10 {
          exit
        }
      ' snx_install.sh
    )

    if [ -z "$archiveOffset" ]; then
      echo "ERROR: ARCHIVE_OFFSET not found"
      exit 1
    fi

    echo "SNX archive offset: $archiveOffset"

    tail -n +"$archiveOffset" snx_install.sh \
      | bunzip2 -c \
      | tar xf - snx

    test -f snx

    chmod +x snx

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/libexec"

    # Keep writable while patching
    install -m 0755 snx "$out/libexec/snx"

    echo "Original interpreter:"
    patchelf --print-interpreter "$out/libexec/snx" || true

    echo "Required libraries:"
    patchelf --print-needed "$out/libexec/snx" || true

    patchelf \
      --set-interpreter "${i686.glibc}/lib/ld-linux.so.2" \
      "$out/libexec/snx"

    patchelf \
      --set-rpath "${
        lib.makeLibraryPath [
          i686.glibc
          i686.pam
          i686.xorg.libX11
          i686.stdenv.cc.cc.lib
        ]
      }" \
      "$out/libexec/snx"

    echo "Patched interpreter:"
    patchelf --print-interpreter "$out/libexec/snx"

    echo "Patched RPATH:"
    patchelf --print-rpath "$out/libexec/snx"

    runHook postInstall
  '';

  meta = {
    description = "Check Point SSL Network Extender (SNX)";
    homepage = "https://support.checkpoint.com/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "snx";
  };
}