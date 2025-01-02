{ pkgs, ... }:
{
  # Enable basic drivers
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable hardware acceleration
  hardware.graphics = {
    enable = true;
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

  # Add AMDVLK drivers in addition to Mesa RADV for Vulkan (software chooses)
  hardware.graphics.extraPackages = with pkgs; [
    amdvlk
  ];

  # Fix for black border/scaling issues in GTK apps (can also be solved by using radeon-vulkan instead of amdvlk?)
  environment.sessionVariables = rec {
    GSK_RENDERER = "gl";
    VK_ICD_FILENAMES = /run/opengl-driver/share/vulkan/icd.d/amd_icd64.json;
  };

  # Add LACT (Linux AMDGPU Controller) and daemon
  environment.systemPackages = with pkgs; [
    lact
  ];
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = ["multi-user.target"];
}
