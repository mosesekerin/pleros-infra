# Runbook

All commands run from this repo on your machine unless they start with `(server)`.

| Task | Command |
| --- | --- |
| Deploy latest app code | `make app` |
| Change a secret / env var | `make vault-edit`, then `make app` (rebuilds, since `NEXT_PUBLIC_*` values are baked in at build time) |
| Force a rebuild | `ansible-playbook playbooks/site.yml --tags app -e force_rebuild=true` |
| See what would change | `make check` |
| App logs | `make logs` |
| Shell on the server | `make ssh` |
| Container status | `(server) cd /opt/pleros && docker compose ps` |
| Restart the app | `(server) cd /opt/pleros && docker compose restart app` |
| Cron history | `(server) journalctl -t pleros-cron --since today` |
| Run a cron job now | `(server) sudo /usr/local/bin/pleros-cron /api/cron/reminder-dispatch` |
| Memory / CPU now | `(server) docker stats --no-stream` and `free -h` |

## Roll back the app
Set `app_repo_version` in `inventory/group_vars/all/vars.yml` to the last good commit SHA, then `make app`.
Set it back to `main` once fixed.

## Rebuild from scratch (new server)
New Ubuntu 24.04 server → update the IP in `inventory/hosts.yml` → `make bootstrap` → `make deploy` → update DNS.
Everything needed lives in this repo plus the vault password (`~/.pleros-vault-pass`, also in the password manager).

## Notes
- Docker publishes ports 80/443 directly, past ufw. The app port (3000) is bound to 127.0.0.1 only, so it is never public.
- Upgrading the Contabo plan reboots the server; containers come back on their own (`restart: unless-stopped`).
