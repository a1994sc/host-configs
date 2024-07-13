_: {
  services.comin = {
    enable = true;
    hostname = "puck";
    remotes = [
      {
        name = "origin";
        url = "https://github.com/a1994sc/host-configs.git";
        branches.main.name = "main";
      }
    ];
  };
}
