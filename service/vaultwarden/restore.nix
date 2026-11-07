{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.vaultwardenService;
in
{
  config = mkIf (cfg.enable && cfg.restoreDuplicityBackup) {
    systemd.services.vaultwarden-restore-duplicity = {
      description = "Restore Vaultwarden database from duplicity backup";
      before = [ "vaultwarden.service" ];
      wantedBy = [ "multi-user.target" ];
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
      path = with pkgs; [ postgresql duplicity gnupg ];

      script = ''
        set -e

        DB_NAME="vaultwarden"
        DB_USER="${cfg.databaseUser}"

        # Check if database is already populated
        DB_SIZE=$(sudo -u postgres psql -c "SELECT sum(pg_total_relation_size(schemaname||'.'||tablename)) FROM pg_tables WHERE schemaname = 'public';" $DB_NAME 2>/dev/null | head -n 3 | tail -n 1 || echo "0")

        if [ "$DB_SIZE" != "" ] && [ "$DB_SIZE" != "0" ]; then
          echo "Database already has data, skipping restore"
          exit 0
        fi

        echo "Starting database restore from duplicity backup"

        RESTORE_DIR=$(mktemp -d)
        trap "rm -rf $RESTORE_DIR" EXIT

        # Restore from duplicity
        if [ -d "${cfg.duplicityRestorePath}" ] && [ "$(ls -A ${cfg.duplicityRestorePath})" ]; then
          echo "Restoring from: ${cfg.duplicityRestorePath}"
          duplicity restore --no-encryption "file://${cfg.duplicityRestorePath}" "$RESTORE_DIR" || {
            echo "WARNING: duplicity restore failed, checking for SQL dump..."
          }
        else
          echo "ERROR: No duplicity backups found in ${cfg.duplicityRestorePath}"
          exit 1
        fi

        # Find and restore SQL dump
        SQL_FILE=$(find $RESTORE_DIR -name "*vaultwarden*.sql" -o -name "backup_postgresql*.sql.gz" 2>/dev/null | head -n 1)

        if [ -z "$SQL_FILE" ]; then
          echo "ERROR: No SQL dump found in backup"
          exit 1
        fi

        echo "Restoring from SQL file: $SQL_FILE"

        if [[ "$SQL_FILE" == *.gz ]]; then
          gunzip -c "$SQL_FILE" | sudo -u postgres psql "$DB_NAME"
        else
          sudo -u postgres psql "$DB_NAME" < "$SQL_FILE"
        fi

        echo "Database restore completed successfully"
      '';

      serviceConfig = {
        Type = "oneshot";
        User = "root";
        RemainAfterExit = true;
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };
  };
}
