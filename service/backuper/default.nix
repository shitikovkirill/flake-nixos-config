{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.backuperService;

  getPassphrase = if cfg.pathPhraseFile != null
    then "$(cat ${cfg.pathPhraseFile})"
    else cfg.pathPhrase;

  getS3ClientId = if cfg.s3.clientIdFile != null
    then "$(cat ${cfg.s3.clientIdFile})"
    else cfg.s3.clientId;

  getS3ClientSecret = if cfg.s3.clientSecretFile != null
    then "$(cat ${cfg.s3.clientSecretFile})"
    else cfg.s3.clientSecret;

  getS3BucketName = if cfg.s3.bucketNameFile != null
    then "$(cat ${cfg.s3.bucketNameFile})"
    else cfg.s3.bucketName;

  googleConf = pkgs.writeText "google_conf" ''
    client_config_backend: settings
    client_config:
      client_id: ${cfg.googleDrive.clientId}
      client_secret: ${cfg.googleDrive.clientSecret}
    save_credentials: True
    save_credentials_backend: file
    save_credentials_file: gdrive.cache
    get_refresh_token: True
  '';

  secretGC = if cfg.googleDrive.enable then "GOOGLE_DRIVE_SETTINGS=${"" + googleConf}" else "";

  secretFile = if (cfg.pathPhraseFile != null || cfg.s3.clientIdFile != null || cfg.s3.clientSecretFile != null)
    then "/tmp/duplicity_secret"
    else pkgs.writeText "duplicity_secret" ''
      PASSPHRASE=${cfg.pathPhrase}
      ${secretGC}
    '';

  targetUrl = if cfg.s3.bucketNameFile != null
    then "s3://s3.amazonaws.com/\$(cat ${cfg.s3.bucketNameFile})/rpi4-backups"
    else if cfg.s3.enable then "s3://s3.amazonaws.com/${cfg.s3.bucketName}/rpi4-backups"
    else if cfg.googleDrive.enable then "gdocs://${cfg.googleDrive.username}@gmail.com/duplicity"
    else "file:///var/backup/duplicity";
in
{
  options = {
    services.backuperService = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "Enable incremental encrypted backup service with duplicity.";
      };

      databases = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = lib.mdDoc "List of PostgreSQL database names to backup.";
      };

      pathPhrase = mkOption {
        type = types.str;
        default = "";
        description = lib.mdDoc "Encryption passphrase for duplicity backups (deprecated, use pathPhraseFile).";
      };

      pathPhraseFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = lib.mdDoc "Path to file containing encryption passphrase for duplicity backups.";
      };

      include = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "/var/lib/vaultwarden" ];
        description = lib.mdDoc "List of paths to include in backups.";
      };

      s3 = mkOption {
        type = types.submodule {
          options = {
            enable = mkOption {
              default = false;
              type = types.bool;
              description = "Enable S3 as backup destination.";
            };
            clientId = mkOption {
              type = types.str;
              default = "";
              description = "AWS access key ID (deprecated, use clientIdFile).";
            };
            clientIdFile = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = "Path to file containing AWS access key ID.";
            };
            clientSecret = mkOption {
              type = types.str;
              default = "";
              description = "AWS secret access key (deprecated, use clientSecretFile).";
            };
            clientSecretFile = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = "Path to file containing AWS secret access key.";
            };
            bucketName = mkOption {
              type = types.str;
              default = "";
              description = "S3 bucket name (deprecated, use bucketNameFile).";
            };
            bucketNameFile = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = "Path to file containing S3 bucket name.";
            };
            region = mkOption {
              type = types.str;
              default = "us-east-1";
              description = "AWS region.";
            };
          };
        };
        default = { };
      };

      googleDrive = mkOption {
        type = types.submodule {
          options = {
            enable = mkOption {
              default = false;
              type = types.bool;
              description = "Enable Google Drive as backup destination.";
            };
            clientId = mkOption {
              type = types.str;
              default = "";
              description = "Google Drive OAuth client ID.";
            };
            clientSecret = mkOption {
              type = types.str;
              default = "";
              description = "Google Drive OAuth client secret.";
            };
            username = mkOption {
              type = types.str;
              default = "";
              description = "Google account email for backup destination.";
            };
          };
        };
        default = {
          enable = false;
          clientId = "";
          clientSecret = "";
          username = "";
        };
        description = "Google Drive backup configuration (optional).";
      };
    };
  };

  config = mkIf cfg.enable {
    services.postgresqlBackup = {
      enable = true;
      databases = cfg.databases;
    };

    services.duplicity = {
      enable = true;
      secretFile = "" + secretFile;
      root = "/var/";
      targetUrl = targetUrl;
      extraFlags = [ "--verbosity" "9" "--allow-source-mismatch" ];
      include = [ config.services.postgresqlBackup.location ] ++ cfg.include;
      exclude = [ "**/*" "**/*.prev.sql.gz" ];
      fullIfOlderThan = "1M";
      cleanup = { maxAge = "2M"; };
    };

    systemd.services.duplicity = mkMerge [
      {
        enable = true;
        serviceConfig = { WorkingDirectory = lib.mkForce "/var/lib/duplicity"; };
      }
      (mkIf (cfg.pathPhraseFile != null || cfg.s3.clientIdFile != null || cfg.s3.clientSecretFile != null) {
        preStart = ''
          cat > /tmp/duplicity_secret << 'EOF'
          PASSPHRASE=${getPassphrase}
          ${secretGC}
          EOF
          chmod 400 /tmp/duplicity_secret
        '';
      })
      (mkIf cfg.s3.enable {
        environment = {
          AWS_ACCESS_KEY_ID = getS3ClientId;
          AWS_SECRET_ACCESS_KEY = getS3ClientSecret;
          AWS_DEFAULT_REGION = cfg.s3.region;
        };
      })
    ];
  };
}
