/**
 * Pi Notify Extension
 *
 * Sends a native terminal notification when Pi agent is done and waiting for input.
 * Supports multiple terminal protocols:
 * - OSC 777: Ghostty, iTerm2, WezTerm, rxvt-unicode
 * - OSC 99: Kitty
 * - Windows toast: Windows Terminal (WSL)
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

function windowsToastScript(title: string, body: string): string {
	const type = "Windows.UI.Notifications";
	const mgr = `[${type}.ToastNotificationManager, ${type}, ContentType = WindowsRuntime]`;
	const template = `[${type}.ToastTemplateType]::ToastText01`;
	const toast = `[${type}.ToastNotification]::new($xml)`;
	return [
		`${mgr} > $null`,
		`$xml = [${type}.ToastNotificationManager]::GetTemplateContent(${template})`,
		`$xml.GetElementsByTagName('text')[0].AppendChild($xml.CreateTextNode('${body}')) > $null`,
		`[${type}.ToastNotificationManager]::CreateToastNotifier('${title}').Show(${toast})`,
	].join("; ");
}

function sanitize(value: string): string {
	return value.replace(/[\x00-\x1f\x7f]/g, " ").replace(/[\x07\x1b]/g, " ");
}

function writeTerminalSequence(sequence: string): void {
	if (process.env.TMUX) {
		process.stdout.write(`\x1bPtmux;${sequence.replace(/\x1b/g, "\x1b\x1b")}\x1b\\`);
		return;
	}
	process.stdout.write(sequence);
}

function notifyOSC777(title: string, body: string): void {
	writeTerminalSequence(`\x1b]777;notify;${sanitize(title)};${sanitize(body)}\x07`);
}

function notifyOSC99(title: string, body: string): void {
	// Kitty OSC 99: i=notification id, d=0 means not done yet, p=body for second part
	writeTerminalSequence(`\x1b]99;i=1:d=0;${sanitize(title)}\x1b\\`);
	writeTerminalSequence(`\x1b]99;i=1:p=body;${sanitize(body)}\x1b\\`);
}

function notifyWindows(title: string, body: string): void {
	const { execFile } = require("child_process");
	execFile("powershell.exe", ["-NoProfile", "-Command", windowsToastScript(title, body)]);
}

function notifyMacOS(title: string, body: string): void {
	const { execFile } = require("child_process");
	execFile("osascript", [
		"-e",
		`display notification ${JSON.stringify(body)} with title ${JSON.stringify(title)}`,
	]);
}

function isGhostty(): boolean {
	return process.env.TERM_PROGRAM === "ghostty" || !!process.env.GHOSTTY_BIN_DIR || !!process.env.GHOSTTY_RESOURCES_DIR;
}

function notify(title: string, body: string): void {
	if (process.env.WT_SESSION) {
		notifyWindows(title, body);
	} else if (process.env.KITTY_WINDOW_ID) {
		notifyOSC99(title, body);
	} else if (isGhostty()) {
		notifyOSC777(title, body);
	} else if (process.platform === "darwin") {
		notifyMacOS(title, body);
	} else {
		notifyOSC777(title, body);
	}
}

function isGhosttyFocusedOnMacOS(): boolean | null {
	if (process.platform !== "darwin" || !isGhostty()) {
		return null;
	}

	const { spawnSync } = require("child_process");
	const result = spawnSync(
		"osascript",
		[
			"-e",
			'tell application "System Events" to get name of first application process whose frontmost is true',
		],
		{ encoding: "utf8" },
	);

	if (result.status !== 0) {
		return null;
	}

	return result.stdout.trim() === "Ghostty";
}

function shouldNotify(): boolean {
	const ghosttyFocused = isGhosttyFocusedOnMacOS();
	if (ghosttyFocused !== null) {
		return !ghosttyFocused;
	}
	return true;
}

export default function (pi: ExtensionAPI) {
	pi.on("agent_end", async () => {
		if (!shouldNotify()) {
			return;
		}
		notify("Pi", "Ready for input");
	});
}
