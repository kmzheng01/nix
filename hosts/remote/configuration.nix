{ config, inputs, lib, user, pkgs, ... }:

let
  user="totaltaxamount";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware.nix
      inputs.vscode-server.nixosModules.default
      inputs.sops-nix.nixosModules.default
    ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  nix.settings.trusted-users = [ user ];
  services.vscode-server.enable = true;


  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "Coen Shields";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker"];
    packages = with pkgs; [];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    brightnessctl
    sqlite
    pinentry-curses
  ];

  services.xserver = {
    enable = true;

    displayManager.startx.enable = true;
  };

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
    enableSSHSupport = true;
  };
  
  networking = { 
    nftables.enable = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 /* SSH */];
    };

    interfaces.ens18.ipv4.addresses = [{
      address = "10.1.10.104";
      prefixLength = 24;
    }];

    defaultGateway = "10.1.10.1";
    nameservers = [ "1.1.1.1" ];
    hostName = "remote";
  };

  sops = {
    defaultSopsFile = ./secrets/secrets.yml;

    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
  };

  # Boot loader
  boot.kernelModules = [ "kvm-amd" "kvm-intel"]; # Needed for vm
  boot.tmp.cleanOnBoot = true;

  # VMs
  virtualisation = {
    docker.enable = true;
  };
}
