{ ... }:
{
  # Importing this file declares BOTH independent option sets.
  # Enabling either service is optional.
  imports = [
    ./backuperService
    ./restoreService
  ];
}
