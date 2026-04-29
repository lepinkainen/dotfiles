package main

import (
	"fmt"
	"os"
	"regexp"
	"strings"
)

func normalizeCmd(c string) string {
	switch c {
	case "batcat":
		return "bat"
	case "vim", "nvim":
		return "vi"
	}
	return c
}

var iconMap = map[string]string{
	"fish":    "🐟",
	"bash":    "💩",
	"python3": "🐍",
	"python":  "🐍",
	"git":     "🔀",
	"find":    "🔍",
	"ag":      "🔍",
	"rg":      "🔍",
	"fd":      "🔍",
	"sleep":   "🕓",
	"docker":  "📦",
	"sudo":    "💥",
	"cp":      "💾",
	"rsync":   "💾",
	"dd":      "💾",
	"ssh":     "📡",
	"scp":     "📡",
	"curl":    "🌐",
	"wget":    "🌐",
	"gh":      "🌐",
	"eza":     "🗂️",
	"mc":      "🗂️",
	"vi":      "✏️",
	"hx":      "✏️",
	"nano":    "✏️",
	"bat":     "📃",
	"less":    "📃",
	"cat":     "📃",
	"man":     "📖",
	"task":    "✅",
	"uv":      "⚡",
	"chezmoi": "🏠",
	"claude":  "🤖",
	"pi":      "🤖",
	"codex":   "🤖",
	"brew":    "🍺",
	"code":    "💻",
	"tofu":    "🧱",
	"llm":     "🧠",
	"poetry":  "📜",
	"gemini":  "✨",
	"yt-dlp":  "📥",
	"open":    "🚪",
	"du":      "📏",
	"mkdir":   "📁",
	"mv":      "📦",
	"rm":      "🗑️",
	"go":      "🐹",
}

func commandIcon(c string) string {
	if i, ok := iconMap[c]; ok {
		return i
	}
	return c
}

func commandTitleMode(c string) string {
	switch c {
	case "ssh", "scp":
		return "remote"
	case "vi", "bat", "less", "man":
		return "short"
	}
	return ""
}

func commandDisplayName(c string) string {
	switch c {
	case "pi":
		return "π"
	case "claude":
		return "Claude Code"
	case "codex":
		return "Codex"
	case "gemini":
		return "Gemini"
	}
	return c
}

var (
	versionLikeRe   = regexp.MustCompile(`^v?[0-9]+(\.[0-9]+)+(\s.*)?$`)
	versionPrefixRe = regexp.MustCompile(`^v?\d+(\.\d+)+([-+][A-Za-z0-9._-]+)?\s+`)
	punctPrefixRe   = regexp.MustCompile(`^[[:punct:]✳★☆•·⋅✦✱✲✴✷✸✹✺✻✼✽✾✿❋❊❉❈❇]+\s*`)
	bracketRe       = regexp.MustCompile(`^\[([^\]]+)\]\s*(.*)$`)
	wrappedCmdRe    = regexp.MustCompile(`^(node|bun|deno|python|python3)$`)
)

func isVersionLikeTitle(t string) bool {
	return versionLikeRe.MatchString(t)
}

func hostLabel(h string) string {
	switch h {
	case "hime":
		return "🎬"
	case "raspberryp":
		return "🤖"
	case "prox":
		return "🛠️"
	case "orochi":
		return "🚗"
	}
	runes := []rune(h)
	if len(runes) > 4 {
		return string(runes[:4])
	}
	return h
}

// shortTitle replicates the bash short_title function.
// Strips leading "<normalizedCmd> ", leading "<originalCmd> ",
// trailing " - <ORIGINALCMD>", and the shortest trailing " <~|/>..." suffix.
func shortTitle(rawTitle, normalizedCmd, originalCmd string) string {
	s := rawTitle
	s = strings.TrimPrefix(s, normalizedCmd+" ")
	s = strings.TrimPrefix(s, originalCmd+" ")
	s = strings.TrimSuffix(s, " - "+strings.ToUpper(originalCmd))
	if i := lastSpaceBeforePathChar(s); i >= 0 {
		s = s[:i]
	}
	return s
}

// lastSpaceBeforePathChar finds the last index i where s[i]==' ' and s[i+1] is '~' or '/'.
// Matches bash glob `${var% [~\/]*}` (shortest suffix match starting with space + ~ or /).
func lastSpaceBeforePathChar(s string) int {
	for i := len(s) - 2; i >= 0; i-- {
		if s[i] == ' ' && (s[i+1] == '~' || s[i+1] == '/') {
			return i
		}
	}
	return -1
}

func inferSpecialApp(rawTitle string) string {
	lower := strings.ToLower(rawTitle)
	if strings.Contains(lower, "claude code") || strings.Contains(lower, "claude") {
		return "claude"
	}
	if strings.Contains(lower, "codex") {
		return "codex"
	}
	if strings.Contains(lower, "gemini") {
		return "gemini"
	}
	if lower == "pi" || strings.HasPrefix(lower, "pi ") || strings.HasSuffix(lower, " pi") {
		return "pi"
	}
	if lower == "π" || strings.HasPrefix(lower, "π ") || strings.HasSuffix(lower, " π") {
		return "pi"
	}
	return ""
}

func cleanSpecialTitle(s string) string {
	s = versionPrefixRe.ReplaceAllString(s, "")
	s = punctPrefixRe.ReplaceAllString(s, "")
	return s
}

func arg(i int) string {
	if i < len(os.Args) {
		return os.Args[i]
	}
	return ""
}

func main() {
	cmd := arg(1)
	title := arg(2)
	path := arg(3)

	originalCmd := cmd
	cmd = normalizeCmd(cmd)

	wrappedApp := inferSpecialApp(title)
	if wrappedApp != "" && (wrappedCmdRe.MatchString(cmd) || isVersionLikeTitle(cmd)) {
		originalCmd = wrappedApp
		cmd = wrappedApp
		title = cleanSpecialTitle(title)
	}

	icon := commandIcon(cmd)
	titleMode := commandTitleMode(cmd)

	if m := bracketRe.FindStringSubmatch(title); m != nil {
		remote := hostLabel(m[1])
		remoteTitle := m[2]

		remoteOriginalCmd, _, _ := strings.Cut(remoteTitle, " ")
		remoteCmd := normalizeCmd(remoteOriginalCmd)
		remoteIcon := commandIcon(remoteCmd)
		remoteTitleMode := commandTitleMode(remoteCmd)

		if (cmd == "ssh" || cmd == "scp") && remoteIcon == remoteCmd && remoteTitleMode == "" {
			if remoteTitle != "" {
				fmt.Printf("📡 %s %s", remote, remoteTitle)
			} else {
				fmt.Printf("📡 %s", remote)
			}
			return
		}

		var remoteInfo string
		if remoteTitleMode == "short" {
			remoteInfo = shortTitle(remoteTitle, remoteCmd, remoteOriginalCmd)
		} else {
			remoteInfo = strings.TrimPrefix(remoteTitle, remoteOriginalCmd)
			remoteInfo = strings.TrimLeft(remoteInfo, " \t")
		}

		if remoteInfo != "" {
			fmt.Printf("📡 %s %s %s", remote, remoteIcon, remoteInfo)
		} else {
			fmt.Printf("📡 %s %s", remote, remoteIcon)
		}
		return
	}

	var info string
	switch {
	case titleMode == "remote":
		remoteTitle := strings.TrimPrefix(title, cmd+" ")
		remoteTitle = strings.TrimSuffix(remoteTitle, " - "+strings.ToUpper(originalCmd))
		var remote, remotePath string
		if m := bracketRe.FindStringSubmatch(remoteTitle); m != nil {
			remote = hostLabel(m[1])
			remotePath = m[2]
		} else {
			head, tail, hasSpace := strings.Cut(remoteTitle, " ")
			remote = head
			if hasSpace {
				remotePath = strings.TrimLeft(tail, " \t")
			}
			remote = strings.TrimPrefix(remote, "[")
			remote = strings.TrimSuffix(remote, "]")
			remote = hostLabel(remote)
		}
		if remotePath != "" {
			info = remote + " " + remotePath
		} else {
			info = remote
		}
	case cmd == "pi" || cmd == "claude" || cmd == "codex" || cmd == "gemini":
		if title == "" || isVersionLikeTitle(title) {
			info = commandDisplayName(cmd)
		} else {
			info = title
		}
	case titleMode == "short":
		info = shortTitle(title, cmd, originalCmd)
	default:
		display := path
		if home := os.Getenv("HOME"); home != "" {
			display = strings.Replace(display, home, "~", 1)
		}
		if !strings.Contains(display, "/") {
			info = display
		} else {
			lastSlash := strings.LastIndex(display, "/")
			base := display[lastSlash+1:]
			parentPath := display[:lastSlash]
			parent := parentPath
			if i := strings.LastIndex(parentPath, "/"); i >= 0 {
				parent = parentPath[i+1:]
			}
			var candidate string
			if parent == "" {
				candidate = "/" + base
			} else {
				candidate = parent + "/" + base
			}
			if len(candidate) < 20 {
				info = candidate
			} else {
				info = base
			}
		}
	}

	fmt.Printf("%s %s", icon, info)
}
