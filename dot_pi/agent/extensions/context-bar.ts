import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
const BAR_WIDTH = 20;
const FULL = "█";
const EMPTY = "░";
const EXTENSION_ID = "context-bar";

function clamp(value: number, min: number, max: number): number {
	return Math.max(min, Math.min(max, value));
}

function renderBar(percent: number): string {
	const normalized = clamp(percent, 0, 1);
	const fullCount = Math.round(normalized * BAR_WIDTH);
	return `[${FULL.repeat(fullCount)}${EMPTY.repeat(BAR_WIDTH - fullCount)}]`;
}

function cavemanSuffix(): string {
	const level = (globalThis as typeof globalThis & { __piCavemanLevel?: string }).__piCavemanLevel;
	return level && level !== "off" ? " [caveman]" : "";
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		const updateStatus = () => {
			const usage = ctx.getContextUsage();
			const suffix = cavemanSuffix();

			if (!usage || usage.contextWindow <= 0) {
				ctx.ui.setStatus(EXTENSION_ID, `ctx --${suffix}`);
				return;
			}

			if (usage.tokens == null || usage.percent == null || !Number.isFinite(usage.percent)) {
				ctx.ui.setStatus(EXTENSION_ID, `ctx --/${Math.round(usage.contextWindow / 1000)}k${suffix}`);
				return;
			}

			const ratio = usage.percent / 100;
			const percent = usage.percent.toFixed(1);
			ctx.ui.setStatus(EXTENSION_ID, `ctx ${percent}%/${Math.round(usage.contextWindow / 1000)}k ${renderBar(ratio)}${suffix}`);
		};

		updateStatus();
		const interval = setInterval(updateStatus, 1000);

		pi.on("session_shutdown", async () => {
			clearInterval(interval);
			ctx.ui.setStatus(EXTENSION_ID, "");
		});
	});
}
