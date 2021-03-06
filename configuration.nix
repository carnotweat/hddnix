{ lib, config, pkgs, fetchgit, ... }:

let
  shared = import ../../shared.nix;
  machine = "nixos";
  hostId = "ec64122f";

in
{
  # sops.defaultSopsFile = ./secrets.yaml;
  # sops.secrets.openvpn_prophet_ca = { };
  # sops.secrets.openvpn_prophet_cert = { };
  # sops.secrets.openvpn_prophet_key = { };
  # sops.secrets.openvpn_prophet_tls = { };
  # sops.secrets.openvpn_bower_ca = { };
  # sops.secrets.openvpn_bower_cert = { };
  # sops.secrets.openvpn_bower_key = { };
   _module.args = {
    inherit shared;
  };

  #Boot Config

   imports =
     let
         oldghcs = import (fetchTarball https://github.com/NixOS/nixpkgs/archive/83b35508c6491103cd16a796758e07417a28698b.tar.gz) {
           config = config // { allowBroken = true; };

         };
         # ssh-to-age = import (fetchTarball https://github.com/Mic92/ssh-to-age/archive/main.tar.gz)
         newghcs = import (fetchTarball https://github.com/NixOS/nixpkgs/archive/f682ff93a2778f101d93b68c97278f902523758a.tar.gz) {
           config = config // { allowBroken = true; };
  };
      nur-no-pkgs =
        import (
          builtins.fetchTarball
          "https://github.com/nix-community/NUR/archive/master.tar.gz"
        ) {};
      
    in
     [
  ./hardware-configuration.nix
  #./cachix.nix
  ./prev.nix
  "${builtins.fetchTarball "https://github.com/Mic92/sops-nix/archive/master.tar.gz"}/modules/sops"
  # "${(import ./nix/sources.nix).sops-nix}/modules/sops"
  "${builtins.fetchTarball "https://github.com/Mic92/ssh-to-age/archive/main.tar.gz"}"
  # "${builtins.fetchTarball "https://github.com/icebox-nix/netkit.nix/archive/refs/heads/master.tar.gz"}/modules/snapdrop"
  # nur-no-pkgs.repos.mmilata.modules.jitsi-meet
  # nur-no-pkgs.repos.mpickering.ghc.ghc801
     ];
  #    hardware.deviceTree.enable = true;
  #    hardware.deviceTree.overlays = [
  #      "${/path/to/sopine-baseboard-ethernet.dtbo}"
  # ];
 
  # Uncomment to use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  #cleanup
  #nix.autoOptimiseStore = true;
  # nix.gc = {
  # automatic = true;
  # dates = "weekly";
  # options = "--delete-older-than 30d";
  # };
  # nix.extraOptions = ''
#   min-free = ${toString (100 * 1024 * 1024)}
#   max-free = ${toString (1024 * 1024 * 1024)}
# '';

  # sandbox
  # nix.useSandbox = true;
  # Uncomment to use grub boot loader
  #boot.loader.grub = {
  #  enable = true;
  #  efiSupport = true;
  #  gfxmodeEfi = "1024x768";
  #  device = "nodev";
  #  theme = pkgs.nixos-grub2-theme;
  #  memtest86.enable = true;
  #};
  boot.zfs.enableUnstable = true;

  boot.supportedFilesystems = [ "exfat" "zfs" ];
  boot.cleanTmpDir = true;
  boot.zfs.devNodes = "/dev";
   # fileSystems."/nix" = {
   #   device = "/dev/disk/by-label/nix";
   #   fsType = "ext4";
   #   neededForBoot = true;
   #   options = [ "noatime" ];
   # };

  # Splash screen to make boot look nice
  boot.plymouth.enable = false;

  console.keyMap = "us";
  console.packages = with pkgs; [ terminus_font ];
  console.font = "ter-i32b";
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };
  i18n.extraLocaleSettings = {
    LC_MESSAGES = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  # # Luks support
  systemd.additionalUpstreamSystemUnits = [
    "debug-shell.service"
  ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
    powerUpCommands = ''
      # echo XHC > /proc/acpi/wakeup
    '';
  };
  time.timeZone = "America/New_York";

  networking = {
    hostName = machine;
    inherit hostId;
    #nameservers = [ "127.0.0.1" ];
    networkmanager.enable = true;
    networkmanager.unmanaged = [ "interface-name:ve-*" "ens9" ];
    extraHosts =
      ''
        # If DNS is broke, we still want to be able to deploy
        10.40.33.20 optina.wedlake.lan
        10.40.33.20 crate.wedlake.lan
        10.40.33.20 hydra.wedlake.lan
        10.40.33.1 portal.wedlake.lan
        127.0.0.1 wallet.samg.com
        127.0.0.1 dev.ocf.net
        127.0.0.1 explorer.jormungandr
        127.0.0.1 explorer.cardano
        127.0.0.1 wp.dev
      '';
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "wlp0s20f3";
    };
    firewall = {
      enable = false;
      allowedUDPPorts = [ 53 4919 69 ];
      allowedTCPPorts = [ 4444 8081 3478 3000 8080 5900 3100 3001 ];
    };
  };

  security.pki.certificates = [ shared.wedlake_ca_cert ];

  nix =
    let
      buildMachines = import ../../build-machines.nix;
    in
    {
      settings.sandbox = true;
      settings.cores = 4;
      settings.extra-sandbox-paths = [ "/etc/nsswitch.conf" "/etc/protocols" ];
      autoOptimiseStore = true;
     
      distributedBuilds = true;
      buildMachines = [
      ];
      extraOptions = ''
        binary-caches-parallel-connections = 3
        connect-timeout = 5
        #allowed-uris = https://github.com/NixOS/nixpkgs/archive https://github.com/input-output-hk/nixpkgs/archive
        experimental-features = nix-command flakes
      '';
      #package = pkgs.nixUnstable;
      binaryCaches = [
      "https://aseipp-nix-cache.global.ssl.fastly.net"
      "https://cache.allvm.org/"
    ];

    binaryCachePublicKeys = [
      "gravity.cs.illinois.edu-1:yymmNS/WMf0iTj2NnD0nrVV8cBOXM9ivAkEdO1Lro3U="
    ];

    };
  

  nixpkgs.overlays = [
    (self: super: { nix-direnv = super.nix-direnv.override { enableFlakes = true; }; })
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
    android_sdk.accept_license = true;
    packageOverrides = super:
      let self = super.pkgs; in
      
      {
        
        manymans = with pkgs; buildEnv {
          name = "manymans";
          ignoreCollisions = true;
          paths = [
            man-pages
            posix_man_pages
            stdmanpages
            glibcInfo
          ];
        };
        
      };
  };

  users.groups.plugdev = { };
  users.extraUsers.sam = {
    isNormalUser = true;
    description = "Sam G";
    uid = 1000;
    extraGroups = [ "wheel" "docker" "disk" "video" "libvirtd" "adbusers" "dialout" "plugdev" "cexplorer" ];
    openssh.authorizedKeys.keys = shared.sam_ssh_keys;
  };

  # users.users.snapdrop.group = "snapdrop";
  # users.groups.snapdrop = {};

  users.users.nixosvmtest.initialHashedPassword = "test";
  users.users.nixosvmtest.isNormalUser = true;
  users.users.nixosvmtest.group = "nixosvmtest";
  users.groups.nixosvmtest = {};
  #users.users.cardano-node.isSystemUser = true;

  # profiles.zsh = {
  #   enable = true;
  #   autosuggest = true;
  # };
  programs.bash = {
    interactiveShellInit = ''
      eval "$(direnv hook bash)"
      eval "$(starship init bash)"
    '';
  };
  # profiles.vim = {
  #   enable = true;
  #   dev = true;
  # };

  environment.pathsToLink = [
    "/share/nix-direnv"
  ];
  environment.systemPackages = with pkgs; let
    startSway = pkgs.writeTextFile {
      name = "startsway";
      destination = "/bin/startsway";
      executable = true;
      text = ''
        #! ${pkgs.bash}/bin/bash

        # first import environment variables from the login manager
        systemctl --user import-environment
        # then start the service
        exec systemctl --user start sway.service
      '';
    };

    environment.gnome.excludePackages =  with pkgs.gnome; [
      epiphany
                                                          ];
    
    #trezor = python3Packages.trezor.overrideAttrs (oldAttrs: {
    #  src = python3Packages.fetchPypi {
    #    pname = "trezor";
    #    version = "0.12.2";
    #    sha256 = "sha256:0r0j0y0ii62ppawc8qqjyaq0fkmmb0zk1xb3f9navxp556w2dljv";
    #  };
    #});
  in
  [
    starship
    direnv
    nix-direnv
    # discord
    heimdall-gui
    ledger-live-desktop
    #trezor
    gopass
    # nur.repos.mic92.hello-nur
    jitsi
    arduino
    bazel
    startSway
    avidemux
    strace
    #browser
    #mmh
    #nyxt
    #epiphany
    #eww-wayland
    chromedriver
    firefox
    # network
    netbox
    pulumi-bin
    inxi
    #keys
    ssh-to-age
    ssh-to-pgp 
    #hdl
    yosys
    #  mplayer
    gpgme.dev
    yubioath-desktop
    yubikey-manager
    pinentry-gtk2
    bat
    slurp
    grim
    ripgrep
    opensc
    pavucontrol
    hledger
    psmisc
    #hie82
    sqlite-interactive
    manymans
    hlint
    gist
    dmenu
 #   google-chrome
    gnupg
    gnupg1compat
    containerd
    docker-compose
    docker-client
    niff
    tmate
    htop
    # feh
    # imagemagick
    # magic-wormhole
    # weechat
    pv
    rxvt_unicode-with-plugins
    # termite
    xsel
    keepassx2
    tcpdump
    inetutils
    p11-kit
    openconnect
    openconnect_gnutls
    gnutls
    # nixos
    fira
    rc
    #nixpkgs.publicsuffix-list
    nixos-option
    cachix
    niv
    age
    hey
    service-wrapper
    nixops
    morph
    poetry
    nix-index
    nix-serve
    nixos-shell
    nix-ld
    nixfmt
    # vm
    qemu
    # versioning
    darcs
    mercurial
    nix-prefetch-git
    gitAndTools.gitFull
    gitAndTools.hub
    tig
    unzip
    zip
    scrot
    git-extras
    #tdesktop
    keybase
    keybase-gui
    #slack
    #lisp
    lispPackages.quicklisp
    lispPackages.quicklisp-to-nix
    roswell
    sbcl
    # pdf
    tetex
    #python
    python39Packages.pip
    python39Packages.lxml
    python39Packages.conda
    #microprocessor
    #rpi-eeprom-update
    # linux
    #zsh
    coreutils-prefixed
    step-cli
    step-ca
    busybox
    file
    dpkg
    bc
    openssl
    keychain
    libxml2
    autoconf
    automake
    autogen
    vagrant
    libtool
    gnum4
    cmake
    gcc
    clang
    xinetd
    ispell
    groff
    fzf
    #bintools-unwrapped
    #libvirt
    gnumake
    #neomutt
    #notmuch
    libxfs
    taskwarrior
    jq
    tree
    sshfs
    mkinitcpio-nfs-utils
    #rust
    passerine
    rustup
    # ruby
    yarn
    # julia
    # julia-lts-bin
    #julia
    #elixir
    #elm
    nodejs
    # Haskell
    stack
    ghc
    #haskell.compiler.ghc8104
    cabal-install
    cabal2nix
    bazelisk
    haskellPackages.ghc
    haskellPackages.ghcid
    haskellPackages.hakyll
    # haskellPackages.text 
    haskellPackages.cryptonite
    # Ocaml
    ocaml
    opam
    ocamlPackages.findlib
    ocamlPackages.merlin
    # agda
    agda
    # virtual
    virtmanager
    xdg_utils
    inotifyTools
    zoom-us
    tdlib
  ];

  hardware = {
    system76.enableAll = true;
    enableRedistributableFirmware = true;
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraConfig = "load-module module-switch-on-connect";

    };
    opengl.enable = true;
    opengl.driSupport32Bit = true;
    opengl.extraPackages = [ pkgs.vaapiIntel ];
    facetimehd.enable = true;
    bluetooth = {
      enable = true;
      settings = {
        general = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
  };
  fonts.fontDir.enable = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = with pkgs; [
    # Used by starship for fonts
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    corefonts
    fira # monospaced
    powerline-fonts
    inconsolata
    liberation_ttf
    dejavu_fonts
    bakoma_ttf
    gentium
    ubuntu_font_family
    terminus_font
    unifont # some international languages
  ];
  
  programs = {
    mosh.enable = true;
    zsh.enable = true;
    adb.enable = true;
    light.enable = true;
    sway = {
      enable = true;
      extraPackages = with pkgs; [
        swaylock
        swayidle
        xwayland
        waybar
        mako
        kanshi
      ];
    };
    waybar.enable = true;
    ssh.startAgent = lib.mkForce false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gtk2";
    };
  };

 # services.gnome.core-utilities.enable = false;
  # services = {
  #   openssh = {
  #     enable = true;
  #     # packages = (hpkgs: with hpkgs; [text cryptonite]);
  #     # haskellPackages = pkgs.haskellPackages;
  #   };
  # 
  #   hoogle = {
  #     enable = true;
  #     # packages = (hpkgs: with hpkgs; [text cryptonite]);
  #     haskellPackages = pkgs.haskellPackages;
  #   };
  #netkit.snapdrop.enable = true;
    # tftpd.enable = true;
    # tftpd.path = "/var/tftpd";
#    zfs.trim.enable = true;
#    zfs.autoScrub.enable = true;
#    zfs.autoScrub.pools = [ "zpool" ];
    # zfs.autoSnapshot = {
    #   enable = true;
    #   frequent = 8;
    #   monthly = 1;
    # };
#    lorri.enable = true;
#    trezord.enable = true;
#    resolved.enable = false;
#    pcscd.enable = true;
    #cardano-node = {
    #  environment = "mainnet";
    #  enable = false;
    #  port = 3001;
    #  hostAddr = "0.0.0.0";
    #  systemdSocketActivation = true;
    #  environments = pkgs.cardanoLib.environments;
    #  package = pkgs.cardano-node;
    #  cardanoNodePkgs = pkgs;
    #};
    #cardano-db-sync = {
    #  cluster = "mainnet";
    #  enable = true;
    #  socketPath = "/run/cardano-node/node.socket";
    #  user = "cexplorer";
    #  extended = true;
    #  postgres = {
    #    database = "cexplorer";
    #  };
    #};
    #graphql-engine.enable = false;
    #cardano-graphql = {
    #  enable = false;
    #};
    # postgresql = {
    #   enable = true;
    #   enableTCPIP = false;
    #   settings = {
    #     max_connections = 200;
    #     shared_buffers = "2GB";
    #     effective_cache_size = "6GB";
    #     maintenance_work_mem = "512MB";
    #     checkpoint_completion_target = 0.7;
    #     wal_buffers = "16MB";
    #     default_statistics_target = 100;
    #     random_page_cost = 1.1;
    #     effective_io_concurrency = 200;
    #     work_mem = "10485kB";
    #     min_wal_size = "1GB";
    #     max_wal_size = "2GB";
    #   };
    # printing = {
    #   enable = true;
    #   drivers = [ pkgs.hplip ];
    #   browsing = true;
    # };
    # dbus.enable = true;
    # # acpid.enable = true;
    # upower.enable = true;

    # udev.extraRules =
    #   let
    #     dependencies = with pkgs; [ coreutils gnupg gawk gnugrep ];
    #     clearYubikey = pkgs.writeScript "clear-yubikey" ''
    #       #!${pkgs.stdenv.shell}
    #       export PATH=${pkgs.lib.makeBinPath dependencies};
    #       keygrips=$(
    #         gpg-connect-agent 'keyinfo --list' /bye 2>/dev/null \
    #           | grep -v OK \
    #           | awk '{if ($4 == "T") { print $3 ".key" }}')
    #       for f in $keygrips; do
    #         rm -v ~/.gnupg/private-keys-v1.d/$f
    #       done
    #       gpg --card-status 2>/dev/null 1>/dev/null || true
    #     '';
    #     clearYubikeySam = pkgs.writeScript "clear-yubikey-sam" ''
    #       #!${pkgs.stdenv.shell}
    #       ${pkgs.sudo}/bin/sudo -u sam ${clearYubikey}
    #     '';
    #   in
    #   ''
    #     ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", RUN+="${clearYubikeySam}"
    #     SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1b7c", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
    #     SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="2b7c", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
    #     SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="3b7c", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
    #     SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="4b7c", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
    #     SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1807", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
    #     SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1808", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
    #     SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0000", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
    #     SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0001", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
    #     SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0004", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
    #     KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev", ATTRS{idVendor}=="2c97"
    #     KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev", ATTRS{idVendor}=="2581"
    #   '';
#    udev.packages = [ pkgs.yubikey-personalization ];

    # compton = {
    #   enable = true;
    #   shadowExclude = [ ''"_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"'' ];
    #   opacityRules = [
    #     "95:class_g = 'URxvt' && !_NET_WM_STATE@:32a"
    #     "0:_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"
    #   ];
    # };
    # dnsmasq = {
    #   enable = true;
    #   extraConfig = ''
    #     address=/portal.wedlake.lan/10.40.33.1
    #     address=/crate.wedlake.lan/10.40.33.20
    #     address=/hydra.wedlake.lan/10.40.33.20
    #     address=/unifi.wedlake.lan/10.40.33.20
    #     address=/server.lan.bower-law.com/192.168.0.254
    #     server=/wedlake.lan/10.40.33.1
    #     server=/lan.centrallakerealty.com/10.37.3.2
    #     server=/lan.bower-law.com/192.168.0.254
    #     server=/bower.local/192.168.0.254
    #     server=/lan.centrallakerealty.com/10.37.3.2
    #   '';
    #   servers = [
    #     "8.8.4.4"
    #     "8.8.8.8"
    #   ];
    #   resolveLocalQueries = false;
    # };

    #openvpn = {
    #  servers = {
    #    prophet = {
    #      autoStart = false;
    #      config = ''
    #        client
    #        dev tun
    #        proto udp
    #        remote prophet.samg.com 1195
    #        nobind
    #        persist-key
    #        persist-tun
    #        ca ${config.sops.secrets.openvpn_prophet_ca}
    #        cert ${config.sops.secrets.openvpn_prophet_cert}
    #        key ${config.sops.secrets.openvpn_prophet_key}
    #        tls-auth ${config.sops.secrets.openvpn_prophet_tls}
    #        key-direction 1
    #        comp-lzo
    #        verb 3
    #      '';
    #    };
    #    bower = {
    #      autoStart = false;
    #      config = ''
    #        client
    #        dev tun
    #        proto udp
    #        remote 73.230.94.119 1194
    #        nobind
    #        persist-key
    #        persist-tun
    #        cipher AES-256-CBC
    #        ca ${config.sops.secrets.openvpn_bower_ca}
    #        cert ${config.sops.secrets.openvpn_bower_cert}
    #        key ${config.sops.secrets.openvpn_bower_key}
    #        comp-lzo
    #        verb 3
    #        '';
    #    };
    #  };
    #};
    # keybase.enable = true;
    # kbfs = {
    #   enable = true;
    #   mountPoint = "/keybase";

    # };
    # redshift = {
    #   enable = true;
    #   package = pkgs.gammastep;
    # };
  
  location.provider = "geoclue2";
  #systemd.services.cardano-db-sync.serviceConfig = {
  #  SupplementaryGroups = "cardano-node";
  #  Restart = "always";
  #  RestartSec = "30s";
  #};
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
  };
  virtualisation.libvirtd.enable = false;
  security.sudo.wheelNeedsPassword = false;
  
  # Custom dotfiles for sam user
  environment = {
    etc = {
      "per-user/sam/gitconfig".text = import ../../sam-dotfiles/git-config.nix;
      
    #   # "sway/config".source = ../../sam-dotfiles/sway/config;
    #   # "xdg/waybar/config".source = ../../sam-dotfiles/waybar/config;
    #   # "xdg/waybar/style.css".source = ../../sam-dotfiles/waybar/style.css;
    };

    shellInit = ''
      export GPG_TTY="$(tty)"
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
    '';
  };

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  system.activationScripts.samdotfiles = {
    text = ''
      mkdir -p /home/sam/.config/sway
      ln -sfn /etc/per-user/sam/gitconfig /home/sam/.gitconfig
      ln -sfn /etc/xdg/waybar /home/sam/.config/waybar
    '';
    deps = [ ];
  };

  system.activationScripts.starship =
    let
      starshipConfig = pkgs.writeText "starship.toml" ''
        [username]
        show_always = true
        [hostname]
        ssh_only = true
        [git_commit]
        tag_disabled = false
        only_detached = false
        [memory_usage]
        format = "via $symbol[''${ram_pct}]($style) "
        disabled = false
        threshold = -1
        [time]
        format = '[\[ $time \]]($style) '
        disabled = false
        [[battery.display]]
        threshold = 100
        style = "bold green"
        [[battery.display]]
        threshold = 50
        style = "bold orange"
        [[battery.display]]
        threshold = 20
        style = "bold red"
        [status]
        map_symbol = true
        disabled = false
      '';
    in
    {
      text = ''
        mkdir -p /etc/per-user/shared
        cp ${starshipConfig} /etc/per-user/shared/starship.toml
        mkdir -p /home/sam/.config
        mkdir -p /root/.config
        chown sam:users /home/sam/.config
        chown root /root/.config
        ln -sf /etc/per-user/shared/starship.toml /home/sam/.config/starship.toml
        ln -sf /etc/per-user/shared/starship.toml /root/.config/starship.toml
      '';
      deps = [ ];
    };

  systemd.user.services = { };
  }

  
