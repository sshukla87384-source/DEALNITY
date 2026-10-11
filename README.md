# Dealnity Store — Telegram Digital Products Marketplace

Enterprise-grade Telegram-based marketplace for digital products (license keys, digital accounts, subscriptions, downloads) with an admin panel and a full reseller marketplace program.

## 🚀 Dealnity Store — naye VPS par setup (quick start)

Ye repo **Dealnity Store** brand ke liye alag copy hai — The Crazy Store se poori tarah independent (alag bot, alag database, alag server). Saare features same hain.

1. **Naya bot banao:** Telegram par @BotFather → `/newbot` → token copy karo (chat mein kabhi paste mat karna — sirf server ki `.env` mein).
2. **Domain:** apne domain ke DNS mein `@`, `www`, `api`, `admin` ke A-records naye VPS ke IP par point karo.
3. **Server par (Ubuntu, Docker installed):**
   ```bash
   sudo mkdir -p /opt/dealnity && sudo chown $USER /opt/dealnity
   git clone https://github.com/sshukla87384-source/DEALNITY.git /opt/dealnity
   cd /opt/dealnity && cp .env.example .env && chmod 600 .env
   nano .env
   ```
4. **`.env` mein ye zaroor bharo** (baaki optional):
   - `NODE_ENV=production`, `BOT_MODE=webhook`
   - `BOT_TOKEN`, `BOT_USERNAME` (bina @)
   - `NGINX_DOMAIN=yourdomain.com`, `WEBHOOK_DOMAIN=https://api.yourdomain.com`, `PUBLIC_API_URL=https://api.yourdomain.com`, `NEXT_PUBLIC_API_URL=https://api.yourdomain.com`, `ADMIN_PANEL_ORIGIN=https://admin.yourdomain.com`
   - `DATABASE_URL=postgresql://gis:<POSTGRES_PASSWORD>@postgres:5432/gis`, `REDIS_URL=redis://redis:6379`, `POSTGRES_PASSWORD=<strong password>`
   - `ENCRYPTION_MASTER_KEY`, `JWT_SECRET`, `WEBHOOK_SECRET_PATH`, `TELEGRAM_SECRET_TOKEN` — har ek ke liye `openssl rand -hex 32` (**naye** values; The Crazy Store wale reuse mat karna)
   - `BOT_ADMIN_PASSCODE`, `BOT_ADMIN_IDS` (aapka Telegram numeric ID)
   - `STORE_NAME=Dealnity Store`
5. **Deploy:** `./infrastructure/scripts/deploy.sh full`
6. **`ENCRYPTION_MASTER_KEY` ka offline backup** zaroor rakho — iske bina saved keys/accounts kabhi decrypt nahi honge.
7. Bot mein `/admin` → passcode → payments (UPI / Binance / crypto), products, suppliers sab yahin se set karo.

Order numbers is brand mein `DEAL-2026-000123` format mein aate hain; developer API keys `deal_live_…` se shuru hoti hain.

Update ke liye har baar: `cd /opt/dealnity && ./infrastructure/scripts/deploy.sh full`

## Status

**Design (Phases 1–6):** complete — see [`docs/`](./docs).
**Implemented:** Telegram bot with catalog/cart/wallet + transactional wallet checkout and instant license delivery (Phase 7); production deployment for Hostinger VPS KVM 8 — Docker images, hardened compose stack, nginx+TLS, CI, encrypted off-site backups, runbook ([`docs/deployment/production.md`](./docs/deployment/production.md)).
**Implemented:** admin/reseller REST API (NestJS) — JWT auth with refresh-token rotation, RBAC, catalog/inventory/orders/users/wallets/coupons/tickets/settings/audit/analytics, Swagger.
**Implemented:** admin panel (Next.js 14) — login, dashboard, orders + manual fulfillment, products/variants/pricing, inventory import + audited reveal, users + wallet adjust + roles, withdrawal review, coupons, ticket threads, settings, audit logs. **Next:** reseller portal flows, downloadable-product delivery (S3), broadcasts UI, 2FA, load tests.

## Stack

TypeScript · NestJS · grammY · PostgreSQL + Prisma · Redis + BullMQ · Next.js + Tailwind + shadcn/ui · Docker Compose (Hostinger VPS KVM 8)

## Documentation

| Doc | Path |
|---|---|
| PRD | `docs/01-prd.md` |
| System architecture | `docs/architecture/02-architecture.md` |
| Telegram bot UX | `docs/03-telegram-bot-ux.md` |
| Database design | `docs/architecture/04-database-schema.md` |
| Prisma schema | `packages/database/prisma/schema.prisma` |
| API specification | `docs/api/05-api-spec.md` |
| Security architecture | `docs/architecture/06-security.md` |

## Monorepo layout

```
apps/          api · telegram-bot · worker · admin-panel
packages/      database · core · payments · shared · auth · config · ui
infrastructure/ docker · nginx · scripts
docs/          architecture · api · deployment
```
