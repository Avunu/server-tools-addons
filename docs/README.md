---
title: "Avunu server tools addons"
description:
  "Scheduled Odoo database backups to any FS Storage (S3 and other fsspec protocols),
  with credentials read from environment variables."
---

Scheduled Odoo database backups to any FS Storage (S3 and other fsspec protocols), with
credentials read from environment variables. It is an Odoo 18.0 module built and
maintained by [Avunu LLC](https://avunu.net) for our own client work and published for
anyone to use. The repository extends
[OCA/server-tools](https://github.com/OCA/server-tools): the module adds a backup method
to its `auto_backup`.

## Modules

| Module                                                | What it does                                                                                                                                                                                                                     | Licence           |
| ----------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------- |
| [`auto_backup_fs_storage`](auto_backup_fs_storage.md) | Adds an FS Storage method to OCA `auto_backup`: scheduled database dumps go to any `fs.storage` (S3 and other fsspec protocols), with credentials read from environment variables and the same retention as the built-in methods | AGPL-3.0-or-later |

Each module's README explains why it exists and how it works.

## Branches

`develop` is the default branch and the one pull requests go to. Its code targets Odoo
18.0, the series named in `.odoo-series`. `18.0` follows `develop` automatically (a
workflow fast-forwards it after every push) and is the branch to install or pin. When a
newer Odoo series is maintained, it gets its own branch (`19.0`, …) and changes flow up
to it from `develop`.

## Install

Requires Odoo 18.0 and a PostgreSQL database. Installing a module pulls in the modules
it depends on (see below), and those must be on your `addons_path` first.

With a plain Odoo checkout, clone this repository on its `18.0` branch and add it to the
addons path:

```sh
git clone --branch 18.0 https://github.com/Avunu/server-tools-addons.git
odoo-bin --addons-path=odoo/addons,/path/to/server-tools-addons,<your other addons paths> \
  -d <database> -i auto_backup_fs_storage --stop-after-init
```

With [odoo-nix](https://github.com/Avunu/odoo-nix), add the repository from the dev
shell. `odoo module add` accepts an `owner/repo` and a branch, adds it as a submodule,
and the addons path is regenerated from the folders present (run `direnv reload`
afterwards):

```sh
odoo module add Avunu/server-tools-addons 18.0
```

OCA dependencies can be added by module name, which also adds the OCA repositories that
hold them: `odoo module add auto_backup fs_storage`.

## Dependencies

Each module's `__manifest__.py` is the source of truth. `auto_backup_fs_storage` lists
no Odoo core module directly; it depends on the following. The OCA repositories listed
are the 18.0 branches; clone both, along with whatever their modules need in turn (their
own manifests list it).

| Module                   | Needs from OCA or others                                                                                                                 | Python packages |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| `auto_backup_fs_storage` | `auto_backup` ([OCA/server-tools](https://github.com/OCA/server-tools)) and `fs_storage` ([OCA/storage](https://github.com/OCA/storage)) | none            |

Those two declare Python packages of their own: `paramiko`, `pysftp` and `cryptography`
for `auto_backup`, and `fsspec` for `fs_storage`. The `odoo_backup` storage this module
creates on install uses S3, which needs fsspec's S3 support (`fsspec[s3]`, as the
`fs_storage` README lists).

## Development

The repository carries its own development environment, built by
[odoo-nix](https://github.com/Avunu/odoo-nix) in addons mode. OCB and the repositories
these modules depend on are flake inputs pinned in `flake.lock`, and the Python
environment is locked in `nix/`. You need Nix with flakes, and optionally direnv.

```sh
git clone https://github.com/Avunu/server-tools-addons.git && cd server-tools-addons
direnv allow                  # or: nix develop --no-pure-eval
devenv up                     # PostgreSQL, Odoo and Mailpit
odoo db provision             # a database with every module here installed
odoo test auto_backup_fs_storage
```

After `nix flake update`, or when a module gains a `depends` or a Python requirement,
run `odoo project relock` and commit `flake.lock` and `nix/`. A new dependency on
another repository also needs its input and an `externalSources` entry in `flake.nix`.
See odoo-nix's
[A repository of addons](https://github.com/Avunu/odoo-nix/blob/main/docs/scaffolding/addons-repository.md).

## Tests

Odoo runs a module's tests when you install or update it with `--test-enable`. Select a
module's tests with a `--test-tags` filter and use a throwaway database:

```sh
odoo-bin -c odoo.conf -d <testdb> -i auto_backup_fs_storage \
  --test-enable --test-tags /auto_backup_fs_storage --stop-after-init
```

`auto_backup_fs_storage` has automated tests; its README runs them with this same
command.

## Licence

Every module is licensed under the
[GNU Affero General Public License v3.0 or later](https://github.com/Avunu/server-tools-addons/blob/18.0/LICENSE),
as its `__manifest__.py` also states (`AGPL-3`, Odoo's identifier for version 3).

## Provenance

`auto_backup_fs_storage` moved here, with its history, from
[Avunu/avunu-odoo-addons](https://github.com/Avunu/avunu-odoo-addons) in November 2026,
when Avunu split that repository into one repository per OCA area.
