# CLIdroid

> Ultimate Android Terminal Power Setup - One command to rule them all

Transform your Termux into a full-featured development environment with Claude Code AI, 30+ hardware commands, and the complete Boris Cherny workflow.

## Quick Install

### Option 1: Public Install (if repo is public)
```bash
curl -sL https://raw.githubusercontent.com/PismoAI/CLIdroid/main/install.sh | bash
```

### Option 2: Private Install (with GitHub token)
```bash
curl -sLH "Authorization: token YOUR_GITHUB_TOKEN" \
  https://raw.githubusercontent.com/PismoAI/CLIdroid/main/install.sh | bash
```

### Option 3: Clone and Run
```bash
pkg install git -y
git clone https://github.com/PismoAI/CLIdroid.git
bash CLIdroid/install.sh
```

Then restart Termux and run `claude` to begin.

## What Gets Installed

### Packages (35+)
- **Dev Tools**: git, gh, nodejs, python, clang, make
- **Shell**: tmux, htop, fzf, neofetch
- **Utils**: curl, wget, jq, ripgrep, tree
- **Android**: termux-api, aapt, apksigner, proot

### Termux:API Commands (30+)

| Category | Commands |
|----------|----------|
| **Clipboard** | `clip` (copy/paste) |
| **Notifications** | `notify`, `toast` |
| **Hardware** | `torch`, `vibrate`, `battery`, `brightness`, `volume` |
| **Location** | `location`, `sensors` |
| **Camera/Media** | `photo`, `record`, `play`, `speak`, `listen` |
| **Phone** | `call`, `sms`, `sms-inbox`, `contacts` |
| **Network** | `wifi`, `wifi-scan`, `myip` |
| **Dialogs** | `ask`, `confirm`, `pick` |
| **Files** | `share`, `open`, `download`, `wallpaper` |
| **System** | `wake-lock`, `ssh-server`, `fingerprint` |

### Claude Code (Boris Workflow)

**Slash Commands:**
- `/start` - Begin session properly
- `/plan` - Think through approach
- `/build` - Build and verify
- `/verify` - Check your work
- `/push` - Commit and push
- `/done` - End session

**Subagents:**
- `mobile-verify.md` - Test mobile apps
- `simplify.md` - Clean up code
- `build-check.md` - Validate builds
- `git-help.md` - Git assistance
- `perf-check.md` - Performance analysis

**Pre-allowed Commands:**
50+ bash commands auto-approved for seamless workflow.

### Shell Enhancements

**Git Shortcuts:**
- `gs` = status, `gd` = diff, `gl` = log graph
- `gap "msg"` = add all + commit + push
- `gcl <url>` = clone + cd into repo

**Utilities:**
- `serve [port]` - Quick HTTP server
- `extract <file>` - Any archive format
- `timer [secs]` - Timer with notification
- `weather [city]` - Weather info
- `cheat <topic>` - Cheat sheets

**Auto CLAUDE.md:**
When you `cd` into a git repo without CLAUDE.md, one is automatically created with the project template.

## Requirements

1. **Termux** - Get from [F-Droid](https://f-droid.org/packages/com.termux/) (not Play Store)
2. **Termux:API** - For hardware access, also from F-Droid
3. **Internet** - For package installation

## After Installation

1. **Restart Termux** (swipe away and reopen)

2. **Authenticate GitHub** (first time):
   ```bash
   gh auth login
   ```
   - Choose: GitHub.com > HTTPS > Login with browser
   - Enter the code at github.com/login/device

3. **Start Claude Code**:
   ```bash
   claude
   ```

4. **Get Help**:
   ```bash
   h
   ```

## Files Created

```
~/.bashrc              # Shell configuration
~/.tmux.conf           # tmux configuration
~/.gradle/             # Android build config
~/.ssh/                # SSH keys
~/bin/                 # 30+ command wrappers
~/.claude/
  ├── commands/        # 7 slash commands
  ├── agents/          # 5 subagents
  └── settings.local.json  # Permissions
```

## Troubleshooting

**Claude Code won't install:**
```bash
npm cache clean --force
npm install -g @anthropic-ai/claude-code
```

**Termux:API commands fail:**
- Install Termux:API app from F-Droid
- Grant all permissions when prompted

**Storage access denied:**
```bash
termux-setup-storage
```

## Version History

- **1.0.0** - Initial release

## Credits

Created by [PismoAI](https://github.com/PismoAI)

Based on the Claude Code workflow by Boris Cherny (Creator of Claude Code)

---

*One command. Full power. Pure Android.*
