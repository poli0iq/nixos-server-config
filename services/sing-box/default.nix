{ config, ... }:
{
  networking.firewall.allowedTCPPorts = [ 443 ];

  services.sing-box = {
    enable = true;

    settings =
      let
        host = "${config.networking.hostName}.${config.networking.domain}";
        certPath = "${config.security.acme.certs.${host}.directory}";
      in
      {
        inbounds = [
          {
            type = "vless";
            tag = "vless-in";

            listen = "::";
            listen_port = 443;

            users = [
              {
                name = "poli";
                flow = "xtls-rprx-vision";
                uuid = {
                  _secret = config.sops.secrets.sing-box_poli.path;
                };
              }
            ];

            tls = {
              enabled = true;
              server_name = host;
              certificate_path = "${certPath}/cert.pem";
              key_path = "${certPath}/key.pem";
            };
          }
        ];

        outbounds = [
          {
            type = "direct";
            tag = "direct";
          }
        ];
      };
  };
}
