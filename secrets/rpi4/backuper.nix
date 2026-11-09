{
     sops.secrets.backuper = {
        sopsFile = ./backuper.env;
        format = "dotenv";
        mode = "0400";
    };
}