{ config, ... }: {
  security.acme = {
    acceptTerms = true;

    defaults = {
      email = "poli0iq@disroot.org";
      dnsProvider = "spaceship";
      credentialFiles = {
        SPACESHIP_API_KEY_FILE = config.sops.secrets.spaceship_api_key.path;
        SPACESHIP_API_SECRET_FILE = config.sops.secrets.spaceship_api_secret.path;
      };
    };

    certs = {
      "${config.networking.hostName}.${config.networking.domain}" = { };
    };
  };
}
