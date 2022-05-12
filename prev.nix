{ config, lib, pkgs, ... }:
###
# abstract-structure
#with
#let
#in
## imports
#system.pkgs
#service enable
#user-enable
#version
###
let
#  lib = pkgs.stdenv.lib;
  # workUser = "builder";
  # workHosts = [ "*.nix-community.org"
  #              "192.168.1.*"
  #             ];
in
{
    services.openssh.extraConfig = ''
        # Host build01.nix-community.org
        #      ProxyCommand ssh -i /home/xameer/.ssh/build01.nix-community.org -W build01.nix-c# om
# munity.org:1221 xameers@nixos
             # IdentityFile /home/xameer/.ssh/build01.nix-community.org
             # User xameer
  '';

#{
# {
#     services.ssh = {
#     enable = true;
#     forwardAgent = false;
#     hashKnownHosts = true;
    #controlMaster = "auto";
    #controlPath = "/home/xameer/.ssh/build01.nix-community.org";

  #   matchBlocks = {
  #     "foo-host" = {
  #       hostname = "host.foo.tld";
  #       user = "root";
  #       port = 22;
  #       identityFile = "~/.ssh/id_ecdsa";
  #     };
  #     "bastion-proxy" = {
  #       hostname = "bastion.example.net";
  #       user = "ec2-user";
  #       port = 443;
  #       identityFile = "~/.ssh/id_rsa";
  #       identitiesOnly = true;
  #       dynamicForwards = [ { port = 8080; } ];
  #       extraOptions = {
  #         RequestTTY = "no";
  #       };
  #     };
  #     work = {
  #       host = (lib.concatStringsSep " " workHosts);
  #       user = workUser;
  #       proxyJump = "bastion-proxy";
  #       certificateFile = "~/.ssh/id_ecdsa-cert.pub";
  #       identitiesOnly = true;
  #     };
#  };

  imports =	      	     
    [ 
      ./hardware-configuration.nix
      ./cachix.nix
      # ./ssh.nix
      # ./overlay.nix
      
    ];

# system block
# Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

# zfs
boot.initrd.supportedFilesystems = [ "zfs" ]; 
boot.supportedFilesystems = [ "zfs" ]; 
services.udev.extraRules = ''
  ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
'';


  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';

  
  networking.wireguard.interfaces.wg0 = {
    generatePrivateKeyFile = true;
    privateKeyFile = "/persist/etc/wireguard/wg0";
  };
# containers.dn42 = {
#   hostAddress = "192.168.254.1"; # Transfer Network
#   hostAddress6 = "2001:db08::42"; # Transfer Network
#   localAddress = "116.203.1.5";
#   localAddress6 = "2a01:4f8:c0c:4f7a::2/128";
#   privateNetwork = true;
#   autoStart = true;

#   config = { config, pkgs, ... }: {
#     imports = [
#       ./peers # Folder with a config for every Peer
#       ./dns.nix # Bind with the litschi.dn42 zone deligated
#       ./bird.nix # Bird config for BGP Routing
#       ./networking.nix # Static Network configuration (with firewall)
#       ./nginx.nix # nginx config for litschi.dn42 
#     ];
#     environment.systemPackages = with pkgs; [ 
#       # Network debug tools
#       dnsutils
#       mtr
#       tcpdump
#       wireguard-tools
#     ];
#   }
# }
# {
#   etc."NetworkManager/system-connections" = {
#     source = "/persist/etc/NetworkManager/system-connections/";
#   };
# }

  # services.openssh = {
  #   enable = true;
  #   hostKeys = [
  #     # {
  #     #   path = "/persist/ssh/ssh_host_ed25519_key";
  #     #   type = "ed25519";
  #     # }
  #     {
  #       path = "/home/xameer/.ssh/build01.nix-community.org";
  #       type = "rsa";
  #       bits = 4096;
  #     }
  #   ];
  # };



  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp2s0.useDHCP = true;
  networking.networkmanager.enable = true;
  networking.hostId = "ec64122f";
  networking.hostName = "nixos";
  nixpkgs.config.allowUnfree = true;

# packages

environment.systemPackages = with pkgs; [
    vim 
    wget
    #devops
    appimage-run
    #docker
    docker-client
    docker-compose
    docker
    git
    #element
    element-desktop
    #homeserver
    nginx
    apache-jena
    acme
    wireguard-tools
    terraform
    #zfs
    #make
    #python
    python
    python3
    elixir
    # phone
    # android-studio
        (emacsWithPackagesFromUsePackage {
      # Your Emacs config file. Org mode babel files are also
      # supported.
      # NB: Config files cannot contain unicode characters, since
      #     they're being parsed in nix, which lacks unicode
      #     support.
      # config = ./emacs.org;
      config = ./emacs.el;

      # Package is optional, defaults to pkgs.emacs
      package = pkgs.emacsGit;

      # By default emacsWithPackagesFromUsePackage will only pull in
      # packages with `:ensure`, `:ensure t` or `:ensure <package name>`.
      # Setting `alwaysEnsure` to `true` emulates `use-package-always-ensure`
      # and pulls in all use-package references not explicitly disabled via
      # `:ensure nil` or `:disabled`.
      # Note that this is NOT recommended unless you've actually set
      # `use-package-always-ensure` to `t` in your config.
      alwaysEnsure = true;

      # For Org mode babel files, by default only code blocks with
      # `:tangle yes` are considered. Setting `alwaysTangle` to `true`
      # will include all code blocks missing the `:tangle` argument,
      # defaulting it to `yes`.
      # Note that this is NOT recommended unless you have something like
      # `#+PROPERTY: header-args:emacs-lisp :tangle yes` in your config,
      # which defaults `:tangle` to `yes`.
      alwaysTangle = true;

      # Optionally provide extra packages not in the configuration file.
      extraEmacsPackages = epkgs: [
        epkgs.cask
      ];

      # Optionally override derivations.
      override = epkgs: epkgs // {
        weechat = epkgs.melpaPackages.weechat.overrideAttrs(old: {
          patches = [ ./weechat-el.patch ];
        });
      };
    })
  ];
    nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # services.xserver.libinput.enable = true;
  # # log
  # {
  # services.nginx.virtualHosts."blog.example.com" = {
  #   root = "/var/www/blog.example.com";
  # };
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  # Enable emacs daemon
  services.emacs.enable = true;
  # Configure keymap in X11
  services.xserver.layout = "us";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. 
  # Don't forget to set a password with ‘passwd’ using the root account if you don't use the init# ialPassword field.
  
  # users.users.florent = {
  #   isNormalUser = true;
  #   initialPassword = "code";  # Define the user initial password
  #   extraGroups = [  "adbusers" ]; # wheel to enable ‘sudo’ for the user.
  # };
  users.users.xameer = {
    isNormalUser = true;
    initialPassword = "node";  # Define the user initial password
    extraGroups = [ "wheel" "adbusers" ]; # wheel to enable ‘sudo’ for the user.
  };
  users.users.openssh.group = "openssh";
  users.groups.openssh = {};
  users.users.openssh = {
    isSystemUser = true;
    #initialPassword = "secret";  # Define the user initial password
    #extraGroups = [ "wheel" "openssh" ]; # wheel to enable ‘sudo’ for the user.
  };

  
users.users.xameer.openssh.authorizedKeys.keys = [
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDF3D8eafXHEN5n03JWwzR4mAUjlwjGIAScPjXt7+TwnuVtrGJP5y+s05pB+ca3Q26gvbTKPTsW3qGM20VBM9A+hcy6+rDgtfiBbWAmdwupTHhfrybEC7bdQzlf+2JK/CoY4ndtz0MmZ6jupSsQVTemA3mXuplmdVe0psdi8zVvTH9BgvXH6gDYUeZHiDn4+T4FBGeLfkRpq+x7Fkw9Mzb40CfAyXrLxKpNrCYYSTCgkCFGQS2X+/nyYcChy+rATcUBZYHhVjr0PMN2j+95yANaWx391dkqBCkDCCWqmzdinqyclYYCvzCqA7Oln3psz2UcdDp4Jj/zBjMZRAnYc7/mnhyRO+SUiT952Fj2nXdy0nuVuXSljZKlLbVUghlfRC0wW73pvaSUoU61lYajjpBfOuuKsSvUQOA1VZLj6qd/FOUP9h1mNh4fByD3LekqUg6Z4Za1ZHR8Ze8pvZJ2B58ZW3pdqObor9ShkzWVCgEgVIe2e3UqNB4ow5Nz1cO8VBU= xameer@nixos"
  ];

  programs.ssh.knownHosts."aarch64.nixos.community".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUTz5i9u5H2FHNAmZJyoJfIGyUm/HfGhfwnc142L3ds";

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "aarch64.nixos.community";
        maxJobs = 64;
        sshKey = "/home/xameer/.ssh/build01.nix-community.org";
        sshUser = "xameer";
        system = "aarch64-linux";
        supportedFeatures = [ "big-parallel" ];
      }
    ];
  };

#  programs.adb.enable = true;
  # serve over ssh
  # 	nix.buildMachines = [ {
	#  hostName = "builder";
	#  #system = "x86_64-linux";
  #  system = "aarch64-linux";
	#  # if the builder supports building for multiple architectures, 
	#  # replace the previous line by, e.g.,
	#  systems = ["x86_64-linux" "aarch64-linux"];
	#  maxJobs = 1;
	#  speedFactor = 2;
	#  #supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
  #  supportedFeatures = [ "{}" ];
	#  mandatoryFeatures = [ ];
	# }] ;
	# nix.distributedBuilds = true;
	# # optional, useful when the builder has a faster internet connection than yours
	# nix.extraOptions = ''
	# 	builders-use-substitutes = true
	# '';
	
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # system.stateVersion = "21.05"; # Did you read the comment?

}
