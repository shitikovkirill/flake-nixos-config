{
  fileSystems."/ssd" = {
    device = "/dev/disk/by-uuid/ee91b6be-2ca6-479d-8ed8-1b86305720df";
    fsType = "ext4";
    options = [ "noatime" "nofail" ];
  };
}
