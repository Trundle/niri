{ pkgs, lib, ... }:


{
  xdg.portal.config.niri = {
    default = [ "gnome" "gtk" ];
    "org.freedesktop.impl.portal.Access" = [ "gtk" ];
    "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
  };

  systemd.user.services.niri = {
    description = "A scrollable-tiling Wayland compositor";
    bindsTo = [ "graphical-session.target" ];
    before = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];

    path = lib.mkForce [];

    serviceConfig = {
      Slice = "session.slice";
      Type = "notify";
      ExecStart = "${pkgs.niri}/bin/niri --session";
      PassEnvironment = [ "PATH" ];
    };
  };
}