{ lib, cfg }:
{
  selectedPaths =
    (lib.optionals cfg.postgresql.enable [ "${cfg.postgresql.location}/*.sql.gz" ])
    ++ cfg.include;

  postgresUnits =
    if !cfg.postgresql.enable then [ ]
    else if cfg.databases == [ ] then [ "postgresqlBackup.service" ]
    else map (db: "postgresqlBackup-${db}.service") cfg.databases;
}
