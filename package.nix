{ gnused, jq, runCommand, mustache-go, lib, sqlite, libxslt
, manual, options, test
, ... }:

let version = lib.versions.majorMinor lib.version;
    env = builtins.toFile "env.json" (builtins.toJSON { inherit version; });
    name =
      if test
      then "nixos-dash-docset-${version}-test"
      else "nixos-dash-docset-${version}";

 in runCommand name
      {
        inherit options version env manual;
        maxOptionsToIndex = if test then 100 else 10000000000;
        buildInputs = [ gnused jq mustache-go sqlite libxslt ];
        src = ./src;
        docsetName = "nixos-${version}";
      }
      ./process.sh
