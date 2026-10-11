import { PrismaClient } from "@prisma/client";

/**
 * Singleton Prisma client (connection pooling handled by Prisma engine).
 * In dev, survive hot-reloads without exhausting connections.
 */
const globalForPrisma = globalThis as unknown as { __gisPrisma?: PrismaClient };

export const prisma: PrismaClient =
  globalForPrisma.__gisPrisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === "development" ? ["warn", "error"] : ["error"],
  });

if (process.env.NODE_ENV !== "production") globalForPrisma.__gisPrisma = prisma;

/**
 * Idempotent creation of DB objects Prisma can't express (sequences for
 * human-friendly order/ticket numbers). Called at app boot and from seed.
 */
export async function ensureDbObjects(): Promise<void> {
  await prisma.$executeRawUnsafe(`CREATE SEQUENCE IF NOT EXISTS gis_order_seq START 1`);
  await prisma.$executeRawUnsafe(`CREATE SEQUENCE IF NOT EXISTS gis_ticket_seq START 1`);
}

/**
 * Brand prefix for order numbers: ORDER_PREFIX in .env (2-6 capital letters),
 * "DEAL" by default → DEAL-2026-000123. Read straight from the environment so
 * seeds and scripts that never load the full app config get the same value.
 */
export function orderPrefix(): string {
  const raw = (process.env.ORDER_PREFIX ?? "").trim().toUpperCase();
  return /^[A-Z]{2,6}$/.test(raw) ? raw : "DEAL";
}

/** Invoice number for an order: the brand prefix becomes INV (DEAL-2026-000123 → INV-2026-000123). */
export function invoiceNumberFor(orderNumber: string): string {
  return orderNumber.replace(/^[A-Z]+/, "INV");
}

export async function nextOrderNumber(tx: Pick<PrismaClient, "$queryRawUnsafe">): Promise<string> {
  const rows = await tx.$queryRawUnsafe<Array<{ nextval: bigint }>>(`SELECT nextval('gis_order_seq')`);
  const n = rows[0]?.nextval ?? 1n;
  return `${orderPrefix()}-${new Date().getFullYear()}-${n.toString().padStart(6, "0")}`;
}

export async function nextTicketNumber(tx: Pick<PrismaClient, "$queryRawUnsafe">): Promise<string> {
  const rows = await tx.$queryRawUnsafe<Array<{ nextval: bigint }>>(`SELECT nextval('gis_ticket_seq')`);
  const n = rows[0]?.nextval ?? 1n;
  return `T-${n.toString().padStart(6, "0")}`;
}

export * from "@prisma/client";
