{ pkgs, ... }:
{
  # Enable basic drivers
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable hardware acceleration
  hardware.graphics = {
    enable = true;
    # enable32Bit = true;
    # Add AMDVLK drivers in addition to Mesa RADV for Vulkan (software chooses)
    extraPackages = with pkgs; [
      amdvlk
      # vulkan-loader
      # vulkan-validation-layers
      # vulkan-extension-layer
    ];
  };

  # HIP
  systemd.tmpfiles.rules =
  let
    rocmEnv = pkgs.symlinkJoin {
      name = "rocm-combined";
      paths = with pkgs.rocmPackages; [
        rocblas
        hipblas
        clr
      ];
    };
  in [
    "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  ];

  # Fix for black border/scaling issues in GTK apps (can also be solved by using radeon-vulkan instead of amdvlk?)
  environment.sessionVariables = rec {
    GSK_RENDERER = "gl";
    # NOTE: Sometimes you'll need to specify this var in steam/proton launch options for certain games that require Mesa RADV.
    # You can usually tell when you need to use RADV over AMDVLK if the game crashes as soon as it attempts to render stuff in engine,
    # e.g. switching from cutscene to gameplay
    # Example launch options: VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json %command%
    VK_ICD_FILENAMES = /run/opengl-driver/share/vulkan/icd.d/amd_icd64.json;
  };

  # Add LACT (Linux AMDGPU Controller) and daemon
  environment.systemPackages = with pkgs; [
    lact
  ];
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = ["multi-user.target"];
}
