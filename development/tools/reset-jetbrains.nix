{ writeShellScriptBin }:

{
  reset = name:
    writeShellScriptBin "reset-${name}" ''
      echo "Removing evaluation key for ${name}"
      rm -rf ~/.config/JetBrains/${name}*/eval

      echo "Resetting evalsprt in options.xml for ${name}"
      sed -i '/evlsprt/d' ~/.config/JetBrains/${name}*/options/other.xml

      echo "Remove userPrefs"
      rm -rf ~/.java/.userPrefs

      echo "Change date file for ${name}"
      find ~/.config/JetBrains/${name}* -type d -exec touch -t $(date +"%Y%m%d%H%M") {} +;
      find ~/.config/JetBrains/${name}* -type f -exec touch -t $(date +"%Y%m%d%H%M") {} +;

      echo "Done"
    '';
}
