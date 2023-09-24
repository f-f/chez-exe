{
  inputs = {
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, ... }:
    let supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
    in utils.lib.eachSystem supportedSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        bootpath = if system == "x86_64-darwin"
                   then "${pkgs.chez-racket}/lib/csv${pkgs.chez-racket.version}/ta6osx"
                   else if system == "aarch64-darwin"
                        then "${pkgs.chez-racket}/lib/csv9.5.7.2/tarm64osx"
                        else "${pkgs.chez-racket}/lib/csv${pkgs.chez-racket.version}/ta6le";
        platformSpecificInputs = if system == "x86_64-darwin"
                                 then [ pkgs.darwin.libiconv ]
                                 else if system == "aarch64-darwin"
                                      then [ pkgs.darwin.libiconv ]
                                      else [ pkgs.libuuid ];
      in {

        packages.default = pkgs.stdenv.mkDerivation {
          name = "chez-exe";
          version = "0.0.1";
          src = ./.;

          buildInputs = with pkgs; [
            chez-racket
          ] ++ platformSpecificInputs;

          buildPhase = ''
            mkdir -p $out/{bin,lib}
            scheme --script gen-config.ss \
            --prefix $out \
            --bindir $out/bin \
            --libdir $out/lib \
            --bootpath ${bootpath} \
            --scheme scheme
          '';
        };
      }
    );
}
