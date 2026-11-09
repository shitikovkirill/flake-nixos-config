{
     sops.secrets.backuper = {
        sopsFile = ./backuper.env;
        format = "dotenv";
        mode = "0400";
    };

    sops.secrets.duplicity-target = {
        sopsFile = ./duplicity-target.yaml;
        format = "yaml";
        key = "target";
    };
}