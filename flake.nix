{
  description = "server-tools-addons: Avunu's Odoo addons, developed with odoo-nix (addons mode)";

  inputs = {
    # flake-parts resolves perSystem `pkgs` from an input literally named `nixpkgs`.
    nixpkgs.follows = "odoo-nix/nixpkgs";

    # OCB and every repository the addons depend on, on this branch's series
    # (.odoo-series): source trees (`flake = false`) pinned by flake.lock.
    # `nix flake update` moves them; follow it with `odoo project relock`.
    # Generated from the addons' `depends`: keep it in step with them.
    ocb = {
      url = "github:OCA/OCB/18.0";
      flake = false;
    };
    oca-server-tools = {
      url = "github:OCA/server-tools/18.0";
      flake = false;
    };
    oca-storage = {
      url = "github:OCA/storage/18.0";
      flake = false;
    };
    # >>> odoo-nix: inputs (managed) >>>
    odoo-nix.url = "github:Avunu/odoo-nix/release-2";
    standards-profile = {
      url = "github:Avunu/odoo-standards-profile/v1";
      flake = false;
    };
    # <<< odoo-nix: inputs (managed) <<<
  };

  nixConfig = {
    extra-substituters = [ "https://devenv.cachix.org" ];
    extra-trusted-public-keys = [
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };

  # Outputs:
  #   devShells.<system>.default  devenv: PostgreSQL, Odoo, Mailpit
  #   apps.<system>.relock        regenerate nix/pyproject.toml and nix/uv.lock
  outputs =
    { odoo-nix, ... }@inputs:
    odoo-nix.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports = [ odoo-nix.flakeModules.default ];

        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-linux"
        ];

        perSystem =
          { lib, ... }:
          {
            odoo-nix = {
              enable = true;
              name = "server-tools-addons";
              workspaceRoot = ./.;
              # The one per-branch fact: the series this branch's code targets.
              odooSeries = lib.fileContents ./.odoo-series;
              addons.enable = true;
              coreSource = inputs.ocb;
              externalSources = [
                {
                  name = "server-tools";
                  src = inputs.oca-server-tools;
                }
                {
                  name = "storage";
                  src = inputs.oca-storage;
                }
              ];
            };
          };
      }
    );
}
