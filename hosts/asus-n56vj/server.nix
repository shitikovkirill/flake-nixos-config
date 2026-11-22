# Headless/server profile for this machine — no display manager, no audio.
{ config, pkgs, ... }:

{
  imports = [ ./lid-switch.nix ];

  services.openssh.enable = true;

  # vtb-python Telegram bot - app/worker/local Bot API server as systemd
  # services. Secrets (TELEGRAM_*/APP_DB/APP_RABBITMQ, reusing the existing
  # "vtb" Postgres user) come from ../../secrets/asus-n56vj/secrets.nix's
  # sops.templates."vtb-python.env".
  services.vtb-python = {
    enable = true;
    environmentFile = config.sops.templates."vtb-python.env".path;
  };

  # photo-archiver pipeline - one systemd unit (every worker +
  # publisher/loader) + a migrate oneshot. Sources = minio.home's `photos`
  # bucket (root MinIO credentials) and this host's local photo library
  # (moved to /srv/photo-archiver, group-writable by the photo-archiver
  # system user -- /home/kirill itself is 0700 so the service can't even
  # traverse into it, and deleting a file needs write+execute on its
  # containing directory, not just read), target = the AWS S3 bucket
  # from infra/'s already-deployed CDK stack. cleanup_allowed=true on
  # both: CLEANUP may delete a source's originals once its archive copy
  # in the AWS S3 target is verified.
  services.photo-archiver = {
    enable = true;
    environmentFile = config.sops.templates."photo-archiver.env".path;
    credentialsYaml = config.sops.templates."photo-archiver-credentials.yaml".path;
    sourcesYaml = pkgs.writeText "photo-archiver-sources.yaml" ''
      sources:
        - id: minio-photos
          backend: s3
          bucket: photos
          endpoint_url: http://minio.home
          cleanup_allowed: true
        - id: home-pictures
          backend: folder
          path: /srv/photo-archiver
          cleanup_allowed: true
    '';
    targetsYaml = pkgs.writeText "photo-archiver-targets.yaml" ''
      targets:
        - id: primary-archive
          backend: s3
          bucket: photo-archive-fxrtk0rz
          region: eu-central-1
    '';
  };

  # Defaults to false upstream, but leaving it off here let every ~60s
  # re-scan of home-pictures' local folder re-queue a brand-new duplicate
  # DOWNLOAD job per still-present file (job-id-scoped key, not
  # source+path) -- confirmed live on this host: new uploads were getting
  # buried under that duplicate backlog (DOWNLOAD's own priority is
  # deliberately the lowest) and never reaching UPLOAD at all. Needed
  # specifically because this host's local-folder source can have a
  # large multi-minute backlog; the S3 source doesn't re-list from
  # scratch the same way.
  systemd.services.photo-archiver.environment.PHOTO_ARCHIVER_STABLE_DOWNLOAD_IDEMPOTENCY =
    "true";
  systemd.services.photo-archiver.environment.PHOTO_ARCHIVER_JOB_RETENTION_COMPLETED_DAYS =
    "2";

  services.ecsAnywhere = {
    enable = true;
    cluster = "PhotoSaver-PSClusterE98E69D4-ff8jz33nFro0";
    region = "eu-central-1";
  };

  environment.shellAliases = {
    monitor_off = "echo 1 | sudo tee /sys/class/graphics/fb0/blank";
    monitor_on = "echo 0 | sudo tee /sys/class/graphics/fb0/blank";
    battery = "cat /sys/class/power_supply/BAT0/capacity; cat /sys/class/power_supply/BAT0/status";
  };
}
