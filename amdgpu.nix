{ pkgs, ... }:
{
  # Enable basic drivers
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable hardware acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
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

  environment.sessionVariables = rec {
    # Fix for black border/scaling issues in GTK apps
    GSK_RENDERER = "gl";
    VK_ICD_FILENAMES = /run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json;
    # Use amdvlk by default
    # VK_ICD_FILENAMES = /run/opengl-driver/share/vulkan/icd.d/amd_icd64.json;
    # If a specific game benefits from amdvlk, then add this to your launch options in steam/proton:
    # VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json %command%
  };

  # Add LACT (Linux AMDGPU Controller) and daemon
  environment.systemPackages = with pkgs; [
    lact
  ];
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = ["multi-user.target"];
}
