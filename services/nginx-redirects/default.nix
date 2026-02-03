{ ... }:
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.nginx = {
    enable = true;

    virtualHosts = {
      "polina.rs" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          return = "302 https://poli.0iq.dev$request_uri";
        };

        # Fix HTTP-01
        locations."/.well-known/acme-challenge" = {
          root = "/var/lib/acme/acme-challenge";
        };
      };

      # растпобеда.срб
      "xn--80aacme6cggkk.xn--90a3ac" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          return = "302 https://poli.0iq.dev$request_uri";
        };

        # Fix HTTP-01
        locations."/.well-known/acme-challenge" = {
          root = "/var/lib/acme/acme-challenge";
        };
      };
    };
  };
}
