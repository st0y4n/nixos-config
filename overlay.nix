final: prev: {
  kdePackages = prev.kdePackages.overrideScope (kdeFinal: kdePrev: {
    plasma-workspace = let
      # Use kdePrev to get the original package
      basePkg = kdePrev.plasma-workspace;

      # Use final for the standard environment tools
      xdgdataPkg = final.stdenv.mkDerivation {
        name = "${basePkg.name}-xdgdata";
        buildInputs = [ basePkg ];
        dontUnpack = true;
        dontFixup = true;
        dontWrapQtApps = true;
        installPhase = ''
          mkdir -p $out/share
          ( IFS=:
            for DIR in $XDG_DATA_DIRS; do
              if [[ -d "$DIR" ]]; then
                cp -r $DIR/. $out/share/
                chmod -R u+w $out/share
              fi
            done
          )
        '';
      };

      # Apply the attribute overrides
      derivedPkg = basePkg.overrideAttrs (oldAttrs: {
        preFixup = (oldAttrs.preFixup or "") + ''
          for index in "''${!qtWrapperArgs[@]}"; do
            if [[ "''${qtWrapperArgs[$index]}" == "--prefix" ]] && [[ "''${qtWrapperArgs[$((index+1))]}" == "XDG_DATA_DIRS" ]]; then
              unset -v "qtWrapperArgs[$index]"
              unset -v "qtWrapperArgs[$((index+1))]"
              unset -v "qtWrapperArgs[$((index+2))]"
              unset -v "qtWrapperArgs[$((index+3))]"
            fi
          done
          # Re-index array after unsetting to prevent gaps
          qtWrapperArgs=("''${qtWrapperArgs[@]}")
          qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "${xdgdataPkg}/share")
          qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share")
        '';
      });

    in derivedPkg;
  });
}
