{ pkgs, lib, ... }:


{
  xdg.portal.config.niri.default = [ "gnome" "gtk" ];

  systemd.user.services.niri = {
    description = "A scrollable-tiling Wayland compositor";
    bindsTo = [ "graphical-session.target" ];
    before = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];

    path = lib.mkForce [];

    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.niri}/bin/niri";
      PassEnvironment = [ "PATH" ];
    };
  };
}
