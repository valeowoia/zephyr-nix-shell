{ pkgs ? import <nixpkgs> { }
, extraPkgs ? [ ]
}:

let
  fhs = pkgs.buildFHSUserEnvBubblewrap {
    name = "zephyr-fhs";
    targetPkgs = pkgs: with pkgs; let
      ncurses' = pkgs.ncurses5.overrideAttrs
        (old: {
          configureFlags = old.configureFlags ++ [ "--with-termlib" ];
          postFixup = "";
        });
    in
    (with pkgs; [
      attr
      bc
      binutils
      bzip2
      chrpath
      cpio
      diffstat
      expect
      file
      gcc
      gdb
      git
      gnumake
      hostname
      kconfig-frontends
      libxcrypt
      lz4
      ncurses'
      (ncurses'.override { unicodeSupport = false; })
      patch
      perl
      (python3.withPackages (ps: with ps; [ 
        setuptools
        pyaml
        west
        tkinter
        wheel
        cmake
        psutil
        pyocd
        cbor
        tabulate
        natsort
        can
        bz2file
        anytree
        junit2html
        lpc-checksum
        pillow
        imgtool
        grpcio-tools
        protobuf
        pygithub
        graphviz
        zcbor
        canopen
        packaging
        progress
        psutil
        pylink-square
        pyserial
        requests
        intelhex
        pykwalify
        pyyaml
        pyelftools
        colorama
        ply
        gcovr
        coverage
        pytest
        mypy
        mock
        magic
        lxml
        junitparser
        pylint

      ]))
      rpcsvc-proto
      cmake
      unzip
      util-linux
      wget
      which
      xz
      zlib
      zstd
      bison
      flex
      pkg-config
      gitlint
      yamllint
    ] ++ (with pkgs.xorg; [
      libX11
      libXext
      libXrender
      libXi
      libXtst
      libxcb
    ]) ++ extraPkgs);
    multiPkgs = ps: [ ];
    extraOutputsToInstall = [ "dev" ];
    profile =
      let
        inherit (pkgs) lib;

        setVars = {
          "NIX_DONT_SET_RPATH" = "1";
        };

        exportVars = [
          "LOCALE_ARCHIVE"
          "NIX_CC_WRAPPER_TARGET_HOST_${pkgs.stdenv.cc.suffixSalt}"
          "NIX_CFLAGS_COMPILE"
          "NIX_CFLAGS_LINK"
          "NIX_LDFLAGS"
          "NIX_DYNAMIC_LINKER_${pkgs.stdenv.cc.suffixSalt}"
        ];

        exports =
          (builtins.attrValues (builtins.mapAttrs (n: v: "export ${n}= \"${v}\"") setVars)) ++
          (builtins.map (v: "export ${v}") exportVars);

        passthroughVars = (builtins.attrNames setVars) ++ exportVars;

        nixconf = pkgs.writeText "nixvars.conf" ''
          ${lib.strings.concatStringsSep "\n" exports}

          BB_BASEHASH_IGNORE_VARS += "${lib.strings.concatStringsSep " " passthroughVars}"
        '';
      in
      ''
        export NIX_DYNAMIC_LINKER_${pkgs.stdenv.cc.suffixSalt}="/lib/ld-linux-x86-64.so.2"

        export BB_ENV_PASSTHROUGH_ADDITIONS="${lib.strings.concatStringsSep " " passthroughVars}"

        export BBPOSTCONF="${nixconf}"
      '';
  };
in
fhs.env
