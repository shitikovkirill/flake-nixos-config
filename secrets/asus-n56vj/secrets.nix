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

  # photo-archiver secrets - separate file from pg.yaml/vtb-python.yaml,
  # same reasoning as those: not Postgres-related, scoped to this one
  # app. photo-archiver.yaml is nested YAML (minio: {access_key_id,
  # secret_access_key}, aws: {access_key_id, secret_access_key}) - same
  # `/`-not-`.` nesting rule as vtb-python.yaml above. Create/edit it with
  # `sops secrets/asus-n56vj/photo-archiver.yaml` (the ./.sops.yaml
  # creation_rules entry for secrets/asus-n56vj/*.yaml picks the right
  # keys automatically) -- it does not exist yet, sops creates it empty
  # on first `sops` invocation for a path matching that rule.
  sops.secrets.minio_photos_access_key_id = {
    sopsFile = ./photo-archiver.yaml;
    key = "minio/access_key_id";
  };
  sops.secrets.minio_photos_secret_access_key = {
    sopsFile = ./photo-archiver.yaml;
    key = "minio/secret_access_key";
  };
  sops.secrets.photo_archiver_aws_access_key_id = {
    sopsFile = ./photo-archiver.yaml;
    key = "aws/access_key_id";
  };
  sops.secrets.photo_archiver_aws_secret_access_key = {
    sopsFile = ./photo-archiver.yaml;
    key = "aws/secret_access_key";
  };

  # Composes the existing "photo_archiver" Postgres password with the
  # local RabbitMQ guest account (same as vtb-python's APP_RABBITMQ
  # above -- RabbitMQ isn't exposed off this host) into the
  # EnvironmentFile services.photo-archiver.environmentFile expects - see
  # ../../hosts/asus-n56vj/server.nix.
  sops.templates."photo-archiver.env" = {
    owner = "photo-archiver";
    content = ''
      PHOTO_ARCHIVER_DATABASE_URL=postgresql://photo_archiver:${config.sops.placeholder.postgres_photo_archiver_password}@127.0.0.1:5432/photo_archiver
      PHOTO_ARCHIVER_RABBITMQ_URL=amqp://guest:guest@127.0.0.1:5672/
      PHOTO_ARCHIVER_BACKUP_POLICY_SATISFIED=true
    '';
  };

  # Composes the four secrets above into the credentials.yaml shape
  # app/services/config.py's load_credentials() expects (one entry per
  # configured source/target id -- see
  # ../../hosts/asus-n56vj/server.nix's sourcesYaml/targetsYaml ids).
  sops.templates."photo-archiver-credentials.yaml" = {
    owner = "photo-archiver";
    content = ''
      minio-photos:
        access_key_id: ${config.sops.placeholder.minio_photos_access_key_id}
        secret_access_key: ${config.sops.placeholder.minio_photos_secret_access_key}
      primary-archive:
        access_key_id: ${config.sops.placeholder.photo_archiver_aws_access_key_id}
        secret_access_key: ${config.sops.placeholder.photo_archiver_aws_secret_access_key}
    '';
  };
}
