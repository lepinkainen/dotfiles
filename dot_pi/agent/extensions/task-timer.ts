import type { AssistantMessage } from "@mariozechner/pi-ai";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

function formatElapsed(ms: number): string {
	const totalSeconds = Math.max(0, Math.round(ms / 1000));
	const minutes = Math.floor(totalSeconds / 60);
	const seconds = totalSeconds % 60;
	return minutes > 0 ? `${minutes}m ${seconds}s` : `${seconds}s`;
}

export default function (pi: ExtensionAPI) {
	let startedAt: number | undefined;

	pi.on("session_start", async () => {
		startedAt = undefined;
	});

	pi.on("agent_start", async () => {
		startedAt = Date.now();
	});

	pi.on("agent_end", async (event, ctx) => {
		if (startedAt === undefined) return;

		const elapsed = Date.now() - startedAt;
		startedAt = undefined;

		const lastAssistant = [...event.messages]
			.reverse()
			.find((message): message is AssistantMessage => message.role === "assistant");
		const suffix =
			lastAssistant?.stopReason === "aborted"
				? " (aborted)"
				: lastAssistant?.stopReason === "error"
					? " (error)"
					: "";

		ctx.ui.notify(`Task completed in: ${formatElapsed(elapsed)}${suffix}`, "info");
		ctx.ui.setStatus("task-timer", undefined);
	});
}
