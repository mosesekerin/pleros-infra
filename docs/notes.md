# Migration notes (timestamped log)

Format: `YYYY-MM-DD HH:MM (WAT) - what happened / decided / found`

- 2026-11-15 - Vercel cut Pleros off over unpaid usage bills. Site fully down. Decision: move to a fixed-price VPS (Contabo), DB stays on Neon.
- 2026-11-16 - Decision: start on Contabo's entry plan and measure real usage on the live server instead of local load tests; upgrade if the data says so.
- 2026-11-16 - Findings from the app repo: Vercel region `iad1` (US East); 2 cron jobs (`sogp-reminders` daily 04:20 UTC, `reminder-dispatch` every 5 min); cache headers for SOGP welcome media; DNS on Cloudflare.
- 2026-11-16 - Created `pleros-infra` (Ansible + Docker Compose + Caddy).
