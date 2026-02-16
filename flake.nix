{
  description = "Flake to build PandoraLauncher";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: import nixpkgs { inherit system; };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {

          default = pkgs.rustPlatform.buildRustPackage rec {
            pname = "pandora-launcher";
            version = "2.7.3";

            src = pkgs.fetchFromGitHub {
              owner = "Moulberry";
              repo = "PandoraLauncher";
              rev = "v${version}";
              hash = "sha256-pdeKtN/Zv97LGX4bscR8DwNzHx/Yk15ckDM7MP7oDgg=";
            };

            cargoHash = "sha256-e2QZnwv8Wl4rr+4wCTWhJu9Xq8ZFgJ4iArLc7nRLUuM=";

            nativeBuildInputs = with pkgs; [ pkg-config ];

            buildInputs = with pkgs; [
              openssl
              wayland
              libxkbcommon
              libGL
              vulkan-loader
              libX11
              libxcb
              libXcursor
              libXi
              libXrandr
              dbus
            ];

            postFixup = ''
              patchelf --add-needed libGL.so.1 $out/bin/pandora_launcher
              patchelf --add-needed libvulkan.so.1 $out/bin/pandora_launcher
              patchelf --set-rpath "${pkgs.lib.makeLibraryPath buildInputs}" $out/bin/pandora_launcher
            '';

            meta = with pkgs.lib; {
              description = "Modern Minecraft launcher";
              homepage = "https://github.com/Moulberry/PandoraLauncher";
              license = licenses.mit;
              mainProgram = "pandora_launcher";
            };
          };
        }
      );
    };
}
