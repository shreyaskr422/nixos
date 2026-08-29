{ ... }: 
{
  networking = {
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      wifi.powersave = false;
    };
  };

  networking.modemmanager.enable = false;
  programs.kdeconnect.enable = true;

  environment.etc."NetworkManager/conf.d/dns-override.conf".text = ''
  [connection]
  ipv4.ignore-auto-dns=true
  ipv6.ignore-auto-dns=true
  '';

  #services.resolved = {
  #  enable = true;
  #  settings.Resolve = {
  #    DNS = [
  #      "12.12.12.12#abcdef.dns.nextdns.io"
  #      "1234:1234::#abcdef.dns.nextdns.io"
  #      "12.12.12.12#abcdef.dns.nextdns.io"
  #      "1234:1234::#abcdef.dns.nextdns.io"
  #    ];
  #    Domains = [ "~." ];
  #    DNSOverTLS = "yes";
  #    DNSSEC = "allow-downgrade";
  #    FallbackDNS = [ ];
  #    LLMNR = false;
  #    MulticastDNS = false;
  #  };
  #};
}
