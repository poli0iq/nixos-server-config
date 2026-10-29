{ config, ... }:
{
  security.acme = {
    acceptTerms = true;

    defaults = {
      email = "poli@0iq.dev";
    };
  };

  # HTTP-01 challenge is served by nginx
  services.nginx.virtualHosts."${config.networking.hostName}.${config.networking.domain}" = {
    enableACME = true;
    locations."/".return = "404";
  };
}
