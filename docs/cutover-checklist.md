# Cutover checklist: Vercel → our server

## Before testing on new.pleros.org
- [ ] Neon region confirmed and server region matches (Vercel ran in `iad1`, US East)
- [ ] All production env vars in the vault (`make vault-edit`)
- [ ] Ask Olamide what `VERCEL_ENV` controls in the code; vault sets it to `production`
- [ ] Cloudflare: add `A` record `new` → server IP, **DNS only (grey cloud)** while testing
- [ ] `make deploy` succeeds; `https://new.pleros.org` loads

## Test on new.pleros.org
- [ ] Main pages load; check `make logs` for errors
- [ ] Google login: add `https://new.pleros.org` to the OAuth client's authorized origins / redirect URIs (Google Cloud console), or test login only after cutover
- [ ] Note: auth and site URLs in the vault point to `https://pleros.org`, so some links/redirects will go to the live domain during the test. Expected.
- [ ] Uploads (UploadThing), emails (Resend), push notifications: test only if safe with real users' data

## Cutover
- [ ] In `vars.yml`: `serve_production_domain: true` and `cron_enabled: true`, then `make deploy`
- [ ] Cloudflare: point `pleros.org` and `www` `A` records to the server IP
- [ ] Cloudflare SSL/TLS mode: **Full (strict)** if the orange-cloud proxy is on
- [ ] Telegram SOGP bot: re-register the webhook if its URL changed (`setWebhook`)
- [ ] Paystack dashboard: confirm webhook / callback URLs use `https://pleros.org`
- [ ] Check cron runs: `journalctl -t pleros-cron` shows `ok` every 5 minutes
- [ ] UptimeRobot monitor on `https://pleros.org`
- [ ] Announce to Pastor Daniel and Olamide; note the time in `docs/notes.md`

## After
- [ ] Remove the `new` DNS record (or keep it as staging)
- [ ] Monitoring: Grafana Cloud agent (next step)
- [ ] Backups of server config are this repo; database backups stay with Neon
