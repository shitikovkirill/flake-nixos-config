{ config, ... }:
{
  sops.defaultSopsFile = ./pg.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets.postgres_vtb_password = {
    owner = "postgres";
    group = "postgres";
  };
  sops.secrets.postgres_photo_archiver_password = {
    owner = "postgres";
    group = "postgres";
  };
  sops.secrets.pgadmin_password = { };

  # vtb-python Telegram bot secrets - separate file from pg.yaml since
  # these aren't Postgres-related; reuses the existing "vtb" Postgres
  # user/database (postgres_vtb_password above) instead of provisioning
  # a new one. vtb-python.yaml is nested YAML (telegram: {token, api_id,
  # api_hash}) - sops-install-secrets addresses nested keys with `/`, NOT
  # `.` (see pkgs/sops-install-secrets/main.go's lookup loop).
  sops.secrets.telegram_token = {
    sopsFile = ./vtb-python.yaml;
    key = "telegram/token";
  };
  sops.secrets.telegram_api_id = {
    sopsFile = ./vtb-python.yaml;
    key = "telegram/api_id";
  };
  sops.secrets.telegram_api_hash = {
    sopsFile = ./vtb-python.yaml;
    key = "telegram/api_hash";
  };

  # Composes the three secrets above plus the existing "vtb" Postgres
  # password into the EnvironmentFile services.vtb-python.environmentFile
  # expects (TELEGRAM_*/APP_DB/APP_RABBITMQ) - see
  # ../../hosts/asus-n56vj/server.nix and vtb-python's
  # docs/pages/deployment/nixos.md.
  sops.templates."vtb-python.env" = {
    owner = "vtb-python";
    content = ''
      TELEGRAM_TOKEN=${config.sops.placeholder.telegram_token}
      TELEGRAM_API_ID=${config.sops.placeholder.telegram_api_id}
      TELEGRAM_API_HASH=${config.sops.placeholder.telegram_api_hash}
      APP_DB=postgresql+asyncpg://vtb:${config.sops.placeholder.postgres_vtb_password}@127.0.0.1:5432/vtb
      APP_RABBITMQ=amqp://guest:guest@127.0.0.1:5672/
    '';
  };
}
