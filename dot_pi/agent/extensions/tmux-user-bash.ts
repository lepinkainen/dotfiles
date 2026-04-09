import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { spawnSync } from "node:child_process";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

function shellQuote(value: string): string {
	return `'${value.replace(/'/g, `'"'"'`)}'`;
}

export default function (pi: ExtensionAPI) {
	pi.on("user_bash", async (event) => {
		if (!process.env.TMUX) {
			return;
		}

		const tempDir = mkdtempSync(join(tmpdir(), "pi-tmux-bash-"));
		const commandFile = join(tempDir, "command.txt");
		const outputFile = join(tempDir, "output.txt");
		const statusFile = join(tempDir, "status.txt");
		const runnerFile = join(tempDir, "runner.sh");
		const token = `pi-user-bash-${process.pid}-${Date.now()}-${Math.random().toString(36).slice(2)}`;

		writeFileSync(commandFile, event.command, "utf8");
		writeFileSync(
			runnerFile,
			`#!/usr/bin/env bash
set +e
cwd="$1"
command_file="$2"
output_file="$3"
status_file="$4"
token="$5"

cleanup() {
	tmux wait-for -S "$token" >/dev/null 2>&1 || true
}
trap cleanup EXIT

cd "$cwd" || {
	echo "Failed to cd to: $cwd" | tee "$output_file"
	echo 1 > "$status_file"
	echo
	printf 'Press any key to close... '
	read -r -n 1 _ < /dev/tty
	exit 1
}

bash -lc "$(cat \"$command_file\")" 2>&1 | tee "$output_file"
status=$PIPESTATUS
echo "$status" > "$status_file"
echo
printf 'Command exited with code %s. Press any key to close... ' "$status"
read -r -n 1 _ < /dev/tty
exit "$status"
`,
			{ mode: 0o755 },
		);

		const shellCommand = [runnerFile, event.cwd, commandFile, outputFile, statusFile, token]
			.map(shellQuote)
			.join(" ");

		try {
			const split = spawnSync(
				"tmux",
				["split-window", "-v", "-c", event.cwd, shellCommand],
				{ encoding: "utf8" },
			);

			if (split.status !== 0) {
				return {
					result: {
						output: split.stderr || split.stdout || "tmux split-window failed",
						exitCode: split.status ?? 1,
						cancelled: false,
						truncated: false,
					},
				};
			}

			const wait = spawnSync("tmux", ["wait-for", token], { encoding: "utf8" });
			if (wait.status !== 0) {
				return {
					result: {
						output: wait.stderr || wait.stdout || "tmux wait-for failed",
						exitCode: wait.status ?? 1,
						cancelled: false,
						truncated: false,
					},
				};
			}

			const output = (() => {
				try {
					return readFileSync(outputFile, "utf8");
				} catch {
					return "";
				}
			})();
			const statusText = (() => {
				try {
					return readFileSync(statusFile, "utf8").trim();
				} catch {
					return "1";
				}
			})();
			const exitCode = Number.parseInt(statusText, 10);

			return {
				result: {
					output,
					exitCode: Number.isFinite(exitCode) ? exitCode : 1,
					cancelled: false,
					truncated: false,
				},
			};
		} finally {
			rmSync(tempDir, { recursive: true, force: true });
		}
	});
}
