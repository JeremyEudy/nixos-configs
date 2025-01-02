{ config, lib, pkgs, ... }:

let
  buildTheme = { name, version, src, themeIni ? [] }:
    pkgs.stdenv.mkDerivation rec {
      pname = "sddm-theme-${name}";
      inherit version src;

      buildCommand = ''
        dir=$out/share/sddm/themes/${name}
        doc=$out/share/doc/${pname}

        mkdir -p $dir $doc
        if [ -d $src/${name} ]; then
          srcDir=$src/${name}
        else
          srcDir=$src
        fi
        cp -r $srcDir/* $dir/
        for f in $dir/{AUTHORS,COPYING,LICENSE,README,*.md,*.txt}; do
          test -f $f && mv $f $doc/
        done
        chmod 644 $dir/theme.conf

        ${lib.concatMapStringsSep "\n" (e: ''
          ${pkgs.crudini}/bin/crudini --set --inplace $dir/theme.conf \
            "${e.section}" "${e.key}" "${e.value}"
        '') themeIni}
      '';
    };

  customTheme = builtins.isAttrs theme;

  # theme = themes.deepin;
  theme = "breeze";

  themeName = if customTheme
  then theme.pkg.name
  else theme;

  packages = if customTheme
  then [ (buildTheme theme.pkg) ] ++ theme.deps
  else [];

  themes = {
    solarized = {
      pkg = rec {
        name = "solarized";
        version = "20190103";
        src = pkgs.fetchFromGitHub {
          owner = "MalditoBarbudo";
          repo = "${name}_sddm_theme";
          rev = "2b5bdf1045f2a5c8b880b482840be8983ca06191";
          sha256 = "1n36i4mr5vqfsv7n3jrvsxcxxxbx73yq0dbhmd2qznncjfd5hlxr";
        };
        themeIni = [
          { section = "General"; key = "background"; value = ./assets/Theater.JPG; }
        ];
      };
      deps = with pkgs; [ font-awesome ];
    };

    # Disabled due to missing assets (rights issue?)
    # sugar-dark = {
    #   pkg = rec {
    #     name = "sugar-dark";
    #     version = "1.2";
    #     src = ./assets/sddm-sugar-dark;
    #     themeIni = [
    #       { section = "General"; key = "background"; value = ./assets/Theater.JPG; }
    #     ];
    #   };
    #   deps = with pkgs; [];
    # };

    # sugar-candy = {
    #   pkg = rec {
    #     name = "sugar-candy";
    #     version = "1.1";
    #     src = ./assets/sddm-sugar-candy;
    #     themeIni = [
    #       { section = "General"; key = "background"; value = ./assets/Theater.JPG; }
    #     ];
    #   };
    #   deps = with pkgs; [];
    # };
  };

in
{
  environment.systemPackages = packages;

  services.displayManager.sddm.theme = "breeze";
}
