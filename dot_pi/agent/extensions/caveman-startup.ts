import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

type CavemanLevel = "off" | "lite" | "full" | "ultra" | "wenyan-lite" | "wenyan-full" | "wenyan-ultra";

const DEFAULT_LEVEL: Exclude<CavemanLevel, "off"> = "full";
let currentLevel: CavemanLevel = DEFAULT_LEVEL;

function publishLevel() {
  (globalThis as typeof globalThis & { __piCavemanLevel?: CavemanLevel }).__piCavemanLevel = currentLevel;
}

const INSTRUCTIONS: Record<CavemanLevel, string> = {
  off: "",
  lite: `Caveman Lite Mode: No filler or hedging. Keep articles and full sentences. Professional but tight. Remove pleasantries like "sure", "certainly", "of course", and "happy to".`,
  full: `Caveman Mode: Respond terse like smart caveman. Drop articles (a, an, the), filler, pleasantries, and hedging. Fragments are OK. Use short synonyms. Keep technical terms exact. Code blocks unchanged. Pattern: [thing] [action] [reason]. [next step].`,
  ultra: `Caveman Ultra Mode: Maximum compression. Abbreviate common technical words where clear. Use arrows for causality. One word when one word is enough. Keep technical terms exact. Code blocks unchanged.`,
  "wenyan-lite": `Wenyan Lite Mode: Semi-classical terse style. Drop filler and hedging but keep enough grammar for clarity. Classical register acceptable. Keep technical terms exact. Code blocks unchanged.`,
  "wenyan-full": `Wenyan Full Mode: Maximum classical terseness. Use 文言文-style concise phrasing while preserving technical accuracy. Keep technical terms exact. Code blocks unchanged.`,
  "wenyan-ultra": `Wenyan Ultra Mode: Extreme abbreviation with classical Chinese feel. Maximum compression while preserving technical accuracy. Keep technical terms exact. Code blocks unchanged.`,
};

const LEVELS: CavemanLevel[] = ["lite", "full", "ultra", "wenyan-lite", "wenyan-full", "wenyan-ultra", "off"];

function formatLevel(level: CavemanLevel): string {
  switch (level) {
    case "off":
      return "Caveman off. Normal mode.";
    case "lite":
      return "Caveman lite active.";
    case "full":
      return "Caveman active. Drop articles, fragments OK.";
    case "ultra":
      return "Caveman ultra active. Max compression.";
    case "wenyan-lite":
      return "Wenyan lite active.";
    case "wenyan-full":
      return "Wenyan full active.";
    case "wenyan-ultra":
      return "Wenyan ultra active.";
  }
}

function parseLevel(args?: string): CavemanLevel | undefined {
  const arg = args?.trim().toLowerCase();
  if (!arg) return undefined;
  const first = arg.split(/\s+/)[0].replace(/[^a-z-]/g, "");
  return LEVELS.includes(first as CavemanLevel) ? (first as CavemanLevel) : undefined;
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("caveman", {
    description: "Toggle caveman mode; default is on at startup. Args: lite, full, ultra, wenyan-lite, wenyan-full, wenyan-ultra, off",
    getArgumentCompletions: (prefix) => {
      return LEVELS.map((level) => ({ value: level, label: level })).filter((item) => item.value.startsWith(prefix));
    },
    handler: async (args, ctx) => {
      const level = parseLevel(args);

      if (!args?.trim()) {
        currentLevel = currentLevel === "off" ? DEFAULT_LEVEL : "off";
      } else if (level) {
        currentLevel = level;
      } else {
        ctx.ui.notify(`Unknown caveman level: ${args}. Use ${LEVELS.join(", ")}.`, "error");
        return;
      }

      publishLevel();
      ctx.ui.notify(formatLevel(currentLevel), "info");
    },
  });

  pi.on("session_start", async (_event, ctx) => {
    currentLevel = DEFAULT_LEVEL;
    publishLevel();
    ctx.ui.notify(formatLevel(currentLevel), "info");
  });

  pi.on("before_agent_start", async (event) => {
    if (currentLevel === "off") return;

    return {
      systemPrompt: `${event.systemPrompt}\n\n${INSTRUCTIONS[currentLevel]}\nOff only when user explicitly asks "stop caveman" or runs /caveman off.`,
    };
  });

  pi.on("input", async (event, ctx) => {
    const text = event.text.toLowerCase();

    if (text.includes("stop caveman") || text.includes("normal mode")) {
      currentLevel = "off";
      publishLevel();
      ctx.ui.notify(formatLevel(currentLevel), "info");
      return { action: "continue" };
    }

    if (text.includes("caveman mode") || text.includes("talk like caveman") || text.includes("use caveman") || text.includes("less tokens") || text.includes("fewer tokens")) {
      if (text.includes("wenyan-ultra")) currentLevel = "wenyan-ultra";
      else if (text.includes("wenyan-full")) currentLevel = "wenyan-full";
      else if (text.includes("wenyan-lite")) currentLevel = "wenyan-lite";
      else if (text.includes("ultra")) currentLevel = "ultra";
      else if (text.includes("lite")) currentLevel = "lite";
      else currentLevel = DEFAULT_LEVEL;

      publishLevel();
      ctx.ui.notify(formatLevel(currentLevel), "info");
    }

    return { action: "continue" };
  });
}
