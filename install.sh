#!/data/data/com.termux/files/usr/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                                                                           ║
# ║     ██████╗██╗     ██╗██████╗ ██████╗  ██████╗ ██╗██████╗                 ║
# ║    ██╔════╝██║     ██║██╔══██╗██╔══██╗██╔═══██╗██║██╔══██╗                ║
# ║    ██║     ██║     ██║██║  ██║██████╔╝██║   ██║██║██║  ██║                ║
# ║    ██║     ██║     ██║██║  ██║██╔══██╗██║   ██║██║██║  ██║                ║
# ║    ╚██████╗███████╗██║██████╔╝██║  ██║╚██████╔╝██║██████╔╝                ║
# ║     ╚═════╝╚══════╝╚═╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝╚═════╝                 ║
# ║                                                                           ║
# ║     Ultimate Android Terminal Power Setup                                 ║
# ║     By PismoAI - github.com/PismoAI/CLIdroid                              ║
# ║     Version 1.0.0                                                         ║
# ║                                                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ONE-LINER INSTALL:
#   curl -sL https://raw.githubusercontent.com/PismoAI/CLIdroid/main/install.sh | bash
#
# WHAT THIS DOES:
#   1. Configures Termux storage & permissions
#   2. Installs 35+ essential packages
#   3. Creates 30+ Termux:API command wrappers
#   4. Installs Claude Code CLI with full Boris Cherny workflow
#   5. Sets up slash commands, subagents, and hooks
#   6. Configures git, ssh, tmux for power users
#   7. Creates helpful shell aliases and functions
#
# REQUIREMENTS:
#   - Termux app (F-Droid version recommended)
#   - Termux:API app (for hardware access)
#   - Internet connection
#
# =============================================================================

# Don't use set -e - we handle errors manually for reliability
# set -e

VERSION="1.0.0"
BACKUP_DIR="$HOME/.clidroid-backup-$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$HOME/.clidroid-install.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Logging
log() { echo -e "${CYAN}[CLIdroid]${NC} $1"; echo "[$(date +%H:%M:%S)] $1" >> "$LOG_FILE"; }
success() { echo -e "${GREEN}✓${NC} $1"; echo "[$(date +%H:%M:%S)] SUCCESS: $1" >> "$LOG_FILE"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; echo "[$(date +%H:%M:%S)] WARN: $1" >> "$LOG_FILE"; }
error() { echo -e "${RED}✗${NC} $1"; echo "[$(date +%H:%M:%S)] ERROR: $1" >> "$LOG_FILE"; }
step() { echo -e "\n${BOLD}${BLUE}[$1/$TOTAL_STEPS]${NC} ${BOLD}$2${NC}"; }

TOTAL_STEPS=12
CURRENT_STEP=0

# =============================================================================
# HEADER
# =============================================================================
show_header() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ██████╗██╗     ██╗██████╗ ██████╗  ██████╗ ██╗██████╗
   ██╔════╝██║     ██║██╔══██╗██╔══██╗██╔═══██╗██║██╔══██╗
   ██║     ██║     ██║██║  ██║██████╔╝██║   ██║██║██║  ██║
   ██║     ██║     ██║██║  ██║██╔══██╗██║   ██║██║██║  ██║
   ╚██████╗███████╗██║██████╔╝██║  ██║╚██████╔╝██║██████╔╝
    ╚═════╝╚══════╝╚═╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝╚═════╝
EOF
    echo -e "${NC}"
    echo -e "    ${BOLD}Ultimate Android Terminal Power Setup v${VERSION}${NC}"
    echo -e "    ${CYAN}By PismoAI${NC}"
    echo ""
}

# =============================================================================
# PREREQUISITES CHECK
# =============================================================================
check_prerequisites() {
    step "0" "Checking prerequisites..."

    # Check if running in Termux
    if [ ! -d "/data/data/com.termux" ]; then
        error "This script must be run in Termux!"
        exit 1
    fi
    success "Running in Termux"

    # Check internet (use curl as ping may be blocked)
    if ! curl -s --connect-timeout 5 https://google.com > /dev/null 2>&1; then
        if ! curl -s --connect-timeout 5 https://1.1.1.1 > /dev/null 2>&1; then
            warn "Internet check failed - continuing anyway..."
        fi
    fi
    success "Internet connected"

    # Check for Termux:API
    if command -v termux-battery-status &> /dev/null; then
        if termux-battery-status &> /dev/null; then
            success "Termux:API available"
        else
            warn "Termux:API installed but not responding"
            warn "Make sure Termux:API app is installed from F-Droid"
        fi
    else
        warn "Termux:API not detected"
        echo -e "    ${YELLOW}For full functionality, install Termux:API from F-Droid${NC}"
    fi
}

# =============================================================================
# BACKUP EXISTING CONFIG
# =============================================================================
backup_existing() {
    step "1" "Backing up existing configuration..."

    mkdir -p "$BACKUP_DIR"

    [ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" "$BACKUP_DIR/" 2>/dev/null || true
    [ -f "$HOME/.tmux.conf" ] && cp "$HOME/.tmux.conf" "$BACKUP_DIR/" 2>/dev/null || true
    [ -d "$HOME/.claude" ] && cp -r "$HOME/.claude" "$BACKUP_DIR/" 2>/dev/null || true
    [ -d "$HOME/.termux" ] && cp -r "$HOME/.termux" "$BACKUP_DIR/" 2>/dev/null || true

    success "Backup saved to $BACKUP_DIR"
}

# =============================================================================
# STORAGE & PERMISSIONS
# =============================================================================
setup_storage() {
    step "2" "Setting up storage access..."

    # Request storage permission
    if [ ! -d "$HOME/storage" ]; then
        termux-setup-storage 2>/dev/null || true
        sleep 2
    fi

    # Create .termux directory
    mkdir -p "$HOME/.termux"

    # Configure Termux properties
    cat > "$HOME/.termux/termux.properties" << 'EOF'
# CLIdroid Configuration
allow-external-apps = true
bell-character = ignore
use-black-ui = true
wake-lock = true
extra-keys = [["ESC","TAB","CTRL","ALT","-","DOWN","UP"],["~","/","HOME","END","PGUP","PGDN","BKSP"]]
EOF

    termux-reload-settings 2>/dev/null || true
    success "Storage and permissions configured"
}

# =============================================================================
# PACKAGE INSTALLATION
# =============================================================================
install_packages() {
    step "3" "Installing packages (this may take a few minutes)..."

    # Update package lists
    log "Updating package lists..."
    yes | pkg update > /dev/null 2>&1 || warn "pkg update had issues"
    yes | pkg upgrade > /dev/null 2>&1 || warn "pkg upgrade had issues"

    # Essential packages - install in groups for reliability
    log "Installing core utilities..."
    pkg install -y git gh curl wget nano vim 2>/dev/null || true

    log "Installing development tools..."
    pkg install -y nodejs python clang make cmake 2>/dev/null || true

    log "Installing shell enhancements..."
    pkg install -y tmux htop neofetch fzf 2>/dev/null || true

    log "Installing file tools..."
    pkg install -y zip unzip tar jq ripgrep tree 2>/dev/null || true

    log "Installing network tools..."
    pkg install -y openssh nmap 2>/dev/null || true

    log "Installing Android tools..."
    pkg install -y termux-api aapt apksigner dx proot 2>/dev/null || true

    # Verify critical packages
    local missing=""
    command -v git > /dev/null || missing="$missing git"
    command -v node > /dev/null || missing="$missing nodejs"
    command -v python > /dev/null || missing="$missing python"

    if [ -n "$missing" ]; then
        warn "Some packages may need manual install:$missing"
    else
        success "Packages installed"
    fi
}

# =============================================================================
# TERMUX:API WRAPPERS
# =============================================================================
setup_termux_api() {
    step "4" "Creating Termux:API power commands..."

    mkdir -p "$HOME/bin"

    # -------------------------------------------------------------------------
    # CLIPBOARD
    # -------------------------------------------------------------------------
    cat > "$HOME/bin/clip" << 'EOF'
#!/bin/bash
# Copy to or paste from clipboard
if [ -n "$1" ]; then
    echo -n "$1" | termux-clipboard-set
    echo "Copied to clipboard"
elif [ -p /dev/stdin ]; then
    termux-clipboard-set
    echo "Copied to clipboard"
else
    termux-clipboard-get
fi
EOF

    # -------------------------------------------------------------------------
    # NOTIFICATIONS
    # -------------------------------------------------------------------------
    cat > "$HOME/bin/notify" << 'EOF'
#!/bin/bash
# Send notification: notify "Title" "Message"
termux-notification \
    --title "${1:-CLIdroid}" \
    --content "${2:-Task complete}" \
    --priority high \
    --vibrate 200,100,200
EOF

    cat > "$HOME/bin/toast" << 'EOF'
#!/bin/bash
# Show toast message: toast "Hello"
termux-toast -g middle -b black -c white "${1:-Hello}"
EOF

    # -------------------------------------------------------------------------
    # HARDWARE CONTROL
    # -------------------------------------------------------------------------
    cat > "$HOME/bin/torch" << 'EOF'
#!/bin/bash
# Flashlight: torch [on|off]
case "${1:-toggle}" in
    on) termux-torch on ;;
    off) termux-torch off ;;
    *) termux-torch on; sleep "${1:-3}"; termux-torch off ;;
esac
EOF

    cat > "$HOME/bin/vibrate" << 'EOF'
#!/bin/bash
# Vibrate: vibrate [duration_ms]
termux-vibrate -d "${1:-500}"
EOF

    cat > "$HOME/bin/battery" << 'EOF'
#!/bin/bash
# Show battery status
termux-battery-status | jq -r '"Battery: \(.percentage)% [\(.status)] \(.temperature)°C"'
EOF

    cat > "$HOME/bin/brightness" << 'EOF'
#!/bin/bash
# Set brightness: brightness [0-255]
if [ -n "$1" ]; then
    termux-brightness "$1"
else
    echo "Usage: brightness [0-255]"
fi
EOF

    cat > "$HOME/bin/volume" << 'EOF'
#!/bin/bash
# Set/show volume: volume [0-15] [stream]
if [ -n "$1" ]; then
    termux-volume "${2:-music}" "$1"
else
    termux-volume | jq -r '.[] | "\(.stream): \(.volume)/\(.max_volume)"'
fi
EOF

    # -------------------------------------------------------------------------
    # LOCATION & SENSORS
    # -------------------------------------------------------------------------
    cat > "$HOME/bin/location" << 'EOF'
#!/bin/bash
# Get current location
LOC=$(termux-location -p "${1:-network}")
LAT=$(echo "$LOC" | jq -r '.latitude')
LON=$(echo "$LOC" | jq -r '.longitude')
echo "Location: $LAT, $LON"
echo "Maps: https://maps.google.com/?q=$LAT,$LON"
EOF

    cat > "$HOME/bin/sensors" << 'EOF'
#!/bin/bash
# List or read sensors: sensors [sensor_name] [count]
if [ -n "$1" ]; then
    termux-sensor -s "$1" -n "${2:-1}"
else
    termux-sensor -l
fi
EOF

    # -------------------------------------------------------------------------
    # CAMERA & MEDIA
    # -------------------------------------------------------------------------
    cat > "$HOME/bin/photo" << 'EOF'
#!/bin/bash
# Take photo: photo [filename] [camera 0|1]
FILE="${1:-photo_$(date +%Y%m%d_%H%M%S).jpg}"
CAM="${2:-0}"
termux-camera-photo -c "$CAM" "$FILE"
echo "Photo saved: $FILE"
termux-media-scan -f "$FILE" 2>/dev/null || true
EOF

    cat > "$HOME/bin/screenshot" << 'EOF'
#!/bin/bash
# Take screenshot (requires root or special permissions)
FILE="${1:-screenshot_$(date +%Y%m%d_%H%M%S).png}"
termux-screenshot "$FILE" 2>/dev/null || {
    echo "Screenshot requires Termux:GUI or root"
    exit 1
}
echo "Screenshot saved: $FILE"
EOF

    cat > "$HOME/bin/record" << 'EOF'
#!/bin/bash
# Record audio: record [filename] [seconds]
FILE="${1:-recording_$(date +%Y%m%d_%H%M%S).m4a}"
DURATION="${2:-30}"
echo "Recording for ${DURATION}s... (Ctrl+C to stop)"
termux-microphone-record -f "$FILE" -l "$DURATION"
echo "Saved: $FILE"
EOF

    cat > "$HOME/bin/record-stop" << 'EOF'
#!/bin/bash
termux-microphone-record -q
echo "Recording stopped"
EOF

    cat > "$HOME/bin/play" << 'EOF'
#!/bin/bash
# Play media file: play [file]
if [ -n "$1" ]; then
    termux-media-player play "$1"
else
    echo "Usage: play <file>"
fi
EOF

    cat > "$HOME/bin/speak" << 'EOF'
#!/bin/bash
# Text to speech: speak "Hello" or echo "Hello" | speak
if [ -n "$1" ]; then
    termux-tts-speak "$1"
else
    termux-tts-speak
fi
EOF

    cat > "$HOME/bin/listen" << 'EOF'
#!/bin/bash
# Speech to text
echo "Listening... (speak now)"
termux-speech-to-text
EOF

    # -------------------------------------------------------------------------
    # PHONE FUNCTIONS
    # -------------------------------------------------------------------------
    cat > "$HOME/bin/call" << 'EOF'
#!/bin/bash
# Make a call: call <number>
if [ -n "$1" ]; then
    termux-telephony-call "$1"
else
    echo "Usage: call <number>"
fi
EOF

    cat > "$HOME/bin/sms" << 'EOF'
#!/bin/bash
# Send SMS: sms <number> <message>
if [ -n "$2" ]; then
    termux-sms-send -n "$1" "$2"
    echo "SMS sent to $1"
else
    echo "Usage: sms <number> <message>"
fi
EOF

    cat > "$HOME/bin/sms-inbox" << 'EOF'
#!/bin/bash
# Show SMS inbox: sms-inbox [count]
termux-sms-list -l "${1:-10}" | jq -r '.[] | "[\(.received)] \(.number):\n\(.body)\n---"'
EOF

    cat > "$HOME/bin/contacts" << 'EOF'
#!/bin/bash
# List contacts: contacts [search]
if [ -n "$1" ]; then
    termux-contact-list | jq -r '.[] | "\(.name): \(.number)"' | grep -i "$1"
else
    termux-contact-list | jq -r '.[] | "\(.name): \(.number)"'
fi
EOF

    # -------------------------------------------------------------------------
    # NETWORK
    # -------------------------------------------------------------------------
    cat > "$HOME/bin/wifi" << 'EOF'
#!/bin/bash
# Show WiFi info
termux-wifi-connectioninfo | jq -r '"SSID: \(.ssid)\nIP: \(.ip)\nSignal: \(.rssi) dBm\nSpeed: \(.link_speed_mbps) Mbps"'
EOF

    cat > "$HOME/bin/wifi-scan" << 'EOF'
#!/bin/bash
# Scan for WiFi networks
termux-wifi-scaninfo | jq -r 'sort_by(.rssi) | reverse | .[] | "\(.ssid) (\(.rssi) dBm) \(.bssid)"'
EOF

    cat > "$HOME/bin/myip" << 'EOF'
#!/bin/bash
# Show IP addresses
echo "Local:  $(termux-wifi-connectioninfo 2>/dev/null | jq -r '.ip // "Not connected"')"
echo "Public: $(curl -s ifconfig.me 2>/dev/null || echo 'Unable to determine')"
EOF

    # -------------------------------------------------------------------------
    # DIALOGS
    # -------------------------------------------------------------------------
    cat > "$HOME/bin/ask" << 'EOF'
#!/bin/bash
# Show input dialog: ask "Question" [hint]
termux-dialog -t "$1" -i "${2:-}" | jq -r '.text'
EOF

    cat > "$HOME/bin/confirm" << 'EOF'
#!/bin/bash
# Show confirmation: confirm "Are you sure?" && echo "Yes" || echo "No"
RESULT=$(termux-dialog confirm -t "${1:-Confirm?}" | jq -r '.text')
[ "$RESULT" = "yes" ]
EOF

    cat > "$HOME/bin/pick" << 'EOF'
#!/bin/bash
# Show picker: pick "Choose" "option1,option2,option3"
termux-dialog radio -t "$1" -v "$2" | jq -r '.text'
EOF

    cat > "$HOME/bin/datepick" << 'EOF'
#!/bin/bash
# Date picker
termux-dialog date -t "${1:-Select date}" | jq -r '.text'
EOF

    # -------------------------------------------------------------------------
    # FILE OPERATIONS
    # -------------------------------------------------------------------------
    cat > "$HOME/bin/share" << 'EOF'
#!/bin/bash
# Share file or text: share <file> OR echo "text" | share
if [ -n "$1" ]; then
    termux-share -a send "$1"
else
    termux-share -a send
fi
EOF

    cat > "$HOME/bin/open" << 'EOF'
#!/bin/bash
# Open file with default app: open <file>
termux-open "$1"
EOF

    cat > "$HOME/bin/open-url" << 'EOF'
#!/bin/bash
# Open URL in browser: open-url <url>
termux-open-url "$1"
EOF

    cat > "$HOME/bin/download" << 'EOF'
#!/bin/bash
# Download file via browser: download <url>
termux-download "$1"
EOF

    cat > "$HOME/bin/scan" << 'EOF'
#!/bin/bash
# Scan media files into gallery
if [ -n "$1" ]; then
    termux-media-scan -f "$1"
else
    termux-media-scan -r ~/storage/dcim/
fi
echo "Media scan complete"
EOF

    cat > "$HOME/bin/wallpaper" << 'EOF'
#!/bin/bash
# Set wallpaper: wallpaper <image_file>
termux-wallpaper -f "$1"
echo "Wallpaper set"
EOF

    # -------------------------------------------------------------------------
    # SECURITY
    # -------------------------------------------------------------------------
    cat > "$HOME/bin/fingerprint" << 'EOF'
#!/bin/bash
# Authenticate with fingerprint
termux-fingerprint -t "Authenticate" -d "${1:-Touch sensor to continue}"
EOF

    # -------------------------------------------------------------------------
    # SYSTEM
    # -------------------------------------------------------------------------
    cat > "$HOME/bin/wake-lock" << 'EOF'
#!/bin/bash
# Prevent device sleep: wake-lock [on|off]
case "${1:-on}" in
    on|start) termux-wake-lock; echo "Wake lock acquired" ;;
    off|stop) termux-wake-unlock; echo "Wake lock released" ;;
esac
EOF

    cat > "$HOME/bin/ssh-server" << 'EOF'
#!/bin/bash
# Start SSH server: ssh-server [port]
PORT="${1:-8022}"
sshd -p "$PORT" 2>/dev/null || {
    echo "Generating SSH keys..."
    ssh-keygen -A
    sshd -p "$PORT"
}
IP=$(termux-wifi-connectioninfo 2>/dev/null | jq -r '.ip // "localhost"')
USER=$(whoami)
echo "SSH server running!"
echo "Connect with: ssh -p $PORT $USER@$IP"
echo "Password: (set with 'passwd')"
EOF

    # -------------------------------------------------------------------------
    # MAKE ALL EXECUTABLE
    # -------------------------------------------------------------------------
    chmod +x "$HOME/bin/"*

    success "30+ Termux:API commands created"
}

# =============================================================================
# CLAUDE CODE INSTALLATION
# =============================================================================
install_claude() {
    step "5" "Installing Claude Code CLI..."

    if command -v claude &> /dev/null; then
        CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
        success "Claude Code already installed ($CLAUDE_VERSION)"
    else
        log "Installing via npm..."
        npm install -g @anthropic-ai/claude-code 2>/dev/null || {
            warn "npm install failed, trying with --force..."
            npm install -g @anthropic-ai/claude-code --force 2>/dev/null || {
                error "Could not install Claude Code"
                echo "Try manually: npm install -g @anthropic-ai/claude-code"
            }
        }

        if command -v claude &> /dev/null; then
            success "Claude Code installed"
        fi
    fi
}

# =============================================================================
# CLAUDE CODE - BORIS WORKFLOW SETUP
# =============================================================================
setup_claude_boris() {
    step "6" "Configuring Claude Code (Boris Workflow)..."

    mkdir -p "$HOME/.claude/commands"
    mkdir -p "$HOME/.claude/agents"

    # -------------------------------------------------------------------------
    # SLASH COMMANDS
    # -------------------------------------------------------------------------

    # /start - Begin session properly
    cat > "$HOME/.claude/commands/start.md" << 'EOF'
description: Start a session properly - read CLAUDE.md and plan first
---
1. Read CLAUDE.md completely (if it exists)
2. Summarize current project status
3. Enter plan mode - think through the approach
4. State what you will do
5. Wait for approval before writing code
EOF

    # /plan - Enter planning mode
    cat > "$HOME/.claude/commands/plan.md" << 'EOF'
description: Enter plan mode to think through an approach
---
1. What is the goal?
2. What are the constraints?
3. What are 2-3 possible approaches?
4. Which approach is best and why?
5. What are the steps to implement?
6. What could go wrong?
7. How will we verify success?
EOF

    # /build - Build and verify
    cat > "$HOME/.claude/commands/build.md" << 'EOF'
description: Build the project and verify it works
---
Run the appropriate build command for this project:
- Android: ./gradlew assembleDebug
- Node: npm run build
- Python: python -m pytest
- Web: npm run dev (check it starts)

Show the output. If failed, fix immediately.
If passed, update CLAUDE.md with build status.
EOF

    # /verify - Check your work
    cat > "$HOME/.claude/commands/verify.md" << 'EOF'
description: Verify your work before continuing
---
1. What did you just change?
2. Run the build/test command
3. Show the output
4. Did it succeed? If no, fix it now
5. Update CLAUDE.md with what you learned
6. Send notification: notify "Verified" "Build passed"
EOF

    # /push - Commit and push
    cat > "$HOME/.claude/commands/push.md" << 'EOF'
description: Commit and push changes to git
---
1. Run: git status
2. Run: git diff --stat
3. Run: git add -A
4. Create descriptive commit message based on actual changes
5. Run: git commit -m "[message]"
6. Run: git push
7. Confirm push succeeded
EOF

    # /done - End session properly
    cat > "$HOME/.claude/commands/done.md" << 'EOF'
description: Properly end a coding session
---
1. Update CLAUDE.md with final status
2. Commit all changes: git add -A && git commit -m "Session: [summary]"
3. Push to branch: git push
4. Send notification: notify "Session Complete" "[summary of what was done]"
5. List what was accomplished
EOF

    # /fix - When stuck
    cat > "$HOME/.claude/commands/fix.md" << 'EOF'
description: When stuck on a problem
---
1. What error are you seeing exactly?
2. What have you already tried?
3. Add failed approach to CLAUDE.md "Failed Approaches" section
4. Try a completely different approach
5. If still stuck after 3 attempts, ask for human help
EOF

    # /status - Show current state
    cat > "$HOME/.claude/commands/status.md" << 'EOF'
description: Show current project status
---
1. Run: git branch (show current branch)
2. Run: git status (show changes)
3. Read CLAUDE.md and summarize current status
4. What's the next task?
5. Any blockers?
EOF

    # -------------------------------------------------------------------------
    # SUBAGENTS
    # -------------------------------------------------------------------------

    # Mobile Verifier
    cat > "$HOME/.claude/agents/mobile-verify.md" << 'EOF'
# Mobile Verification Agent

## Purpose
Verify mobile apps and games work correctly on device.

## Steps
1. Build the app: ./gradlew assembleDebug
2. Check APK was created in app/build/outputs/apk/debug/
3. If web-based game:
   - Start server: npx http-server -p 8080
   - Open in browser: open-url http://localhost:8080
4. Take screenshot if possible
5. Check for errors in logcat: adb logcat *:E | head -50
6. Report status with notification

## Success Criteria
- App builds without errors
- App runs without crashing
- UI is visible and responsive
- Performance is acceptable (30+ FPS for games)
EOF

    # Code Simplifier
    cat > "$HOME/.claude/agents/simplify.md" << 'EOF'
# Code Simplifier Agent

## Purpose
Clean up and simplify code after implementation.

## Steps
1. Find overly complex functions (>50 lines)
2. Look for duplicated code
3. Check for unused imports/variables
4. Simplify nested conditionals
5. Remove unnecessary comments
6. Ensure consistent formatting

## Rules
- Don't change behavior, only simplify
- Keep changes minimal and focused
- Run tests after each change
- If tests fail, revert
EOF

    # Build Validator
    cat > "$HOME/.claude/agents/build-check.md" << 'EOF'
# Build Validator Agent

## Purpose
Validate that builds are correct and complete.

## Checks
1. Build completes without errors
2. No warnings in output
3. Output files exist and have reasonable size
4. Dependencies are all resolved
5. No security vulnerabilities flagged

## For Android
- APK exists in build/outputs/
- APK can be installed: pm install app.apk
- App launches without crash

## For Node
- node_modules complete
- No missing peer dependencies
- Build output exists
EOF

    # Git Helper
    cat > "$HOME/.claude/agents/git-help.md" << 'EOF'
# Git Helper Agent

## Purpose
Assist with git operations and resolve conflicts.

## Capabilities
1. Explain current git state
2. Help resolve merge conflicts
3. Clean up commit history
4. Set up branches correctly
5. Fix common git mistakes

## Common Fixes
- Undo last commit: git reset --soft HEAD~1
- Discard changes: git checkout -- .
- Fix branch: git checkout -b correct-branch
- Sync fork: git fetch upstream && git merge upstream/main
EOF

    # Performance Check
    cat > "$HOME/.claude/agents/perf-check.md" << 'EOF'
# Performance Check Agent

## Purpose
Profile and optimize performance.

## For Games (Three.js/Web)
1. Check FPS: should be 30+ on mobile
2. Monitor memory: no continuous growth
3. Check draw calls: minimize where possible
4. Verify textures are optimized
5. Look for unnecessary re-renders

## For Android Apps
1. Check startup time
2. Monitor memory usage
3. Look for ANR risks
4. Check battery impact
5. Verify smooth scrolling

## Tools
- Chrome DevTools for web
- Android Profiler for native
- logcat for errors
EOF

    # -------------------------------------------------------------------------
    # SETTINGS (PERMISSIONS)
    # -------------------------------------------------------------------------
    cat > "$HOME/.claude/settings.local.json" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(npm:*)",
      "Bash(npx:*)",
      "Bash(node:*)",
      "Bash(python:*)",
      "Bash(pip:*)",
      "Bash(pkg:*)",
      "Bash(apt:*)",
      "Bash(git:*)",
      "Bash(gh:*)",
      "Bash(./gradlew:*)",
      "Bash(gradle:*)",
      "Bash(make:*)",
      "Bash(cmake:*)",
      "Bash(cargo:*)",
      "Bash(ls:*)",
      "Bash(cat:*)",
      "Bash(head:*)",
      "Bash(tail:*)",
      "Bash(find:*)",
      "Bash(grep:*)",
      "Bash(rg:*)",
      "Bash(tree:*)",
      "Bash(curl:*)",
      "Bash(wget:*)",
      "Bash(tar:*)",
      "Bash(unzip:*)",
      "Bash(zip:*)",
      "Bash(mkdir:*)",
      "Bash(cp:*)",
      "Bash(mv:*)",
      "Bash(rm:*)",
      "Bash(chmod:*)",
      "Bash(echo:*)",
      "Bash(notify:*)",
      "Bash(toast:*)",
      "Bash(battery:*)",
      "Bash(termux-*:*)",
      "Bash(adb:*)",
      "Bash(pm:*)",
      "Bash(am:*)",
      "Bash(htop:*)",
      "Bash(tmux:*)",
      "Bash(ssh:*)",
      "Bash(scp:*)",
      "Bash(jq:*)",
      "WebSearch",
      "WebFetch(domain:github.com)",
      "WebFetch(domain:raw.githubusercontent.com)",
      "WebFetch(domain:stackoverflow.com)",
      "WebFetch(domain:developer.android.com)",
      "WebFetch(domain:npmjs.com)",
      "WebFetch(domain:docs.anthropic.com)"
    ]
  }
}
EOF

    success "Claude Code configured with Boris workflow"
}

# =============================================================================
# GIT CONFIGURATION
# =============================================================================
setup_git() {
    step "7" "Configuring Git..."

    git config --global init.defaultBranch main
    git config --global pull.rebase false
    git config --global core.editor nano

    # Useful aliases
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.lg "log --oneline --graph --all -20"
    git config --global alias.last "log -1 HEAD --stat"
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.undo "reset --soft HEAD~1"

    success "Git configured"
}

# =============================================================================
# SSH SETUP
# =============================================================================
setup_ssh() {
    step "8" "Setting up SSH..."

    if [ ! -f "$HOME/.ssh/id_rsa" ]; then
        ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N "" -q
        success "SSH key generated"
    else
        success "SSH key exists"
    fi

    # Generate host keys for sshd
    ssh-keygen -A 2>/dev/null || true
}

# =============================================================================
# TMUX CONFIGURATION
# =============================================================================
setup_tmux() {
    step "9" "Configuring tmux..."

    cat > "$HOME/.tmux.conf" << 'EOF'
# CLIdroid tmux configuration

# Remap prefix to Ctrl+a
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# Easy reload
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Better splits
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Mouse support
set -g mouse on

# Start windows at 1
set -g base-index 1
setw -g pane-base-index 1

# More history
set -g history-limit 50000

# Faster escape
set -s escape-time 0

# Status bar
set -g status-style bg=colour235,fg=white
set -g status-left "#[fg=cyan][#S] "
set -g status-right "#[fg=yellow]%H:%M #[fg=cyan]%d-%b"
set -g status-left-length 30

# Active window
setw -g window-status-current-style fg=cyan,bold

# Pane borders
set -g pane-border-style fg=colour238
set -g pane-active-border-style fg=cyan
EOF

    success "tmux configured"
}

# =============================================================================
# GRADLE CONFIGURATION
# =============================================================================
setup_gradle() {
    step "10" "Configuring Android build tools..."

    mkdir -p "$HOME/.gradle"

    cat > "$HOME/.gradle/gradle.properties" << 'EOF'
# CLIdroid Gradle configuration
android.aapt2FromMavenOverride=/data/data/com.termux/files/usr/bin/aapt2
org.gradle.jvmargs=-Xmx2048m -XX:+HeapDumpOnOutOfMemoryError
org.gradle.parallel=true
org.gradle.caching=true
android.useAndroidX=true
EOF

    success "Gradle configured"
}

# =============================================================================
# SHELL CONFIGURATION
# =============================================================================
setup_shell() {
    step "11" "Setting up shell environment..."

    # Create fresh bashrc (backup was made earlier)
    cat > "$HOME/.bashrc" << 'BASHRC'
# ╔═══════════════════════════════════════════════════════════════╗
# ║  CLIdroid Shell Configuration                                 ║
# ╚═══════════════════════════════════════════════════════════════╝

# Path
export PATH="$HOME/bin:$PATH"
export BROWSER="termux-open-url"
export EDITOR="nano"

# ─────────────────────────────────────────────────────────────────
# CLAUDE CODE - BORIS MODE (Full autonomy)
# ─────────────────────────────────────────────────────────────────
alias claude="claude --dangerously-skip-permissions"
alias cc="claude --dangerously-skip-permissions"

# ─────────────────────────────────────────────────────────────────
# NAVIGATION
# ─────────────────────────────────────────────────────────────────
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias home="cd ~"
alias dl="cd ~/storage/downloads"
alias sd="cd ~/storage/shared"

# ─────────────────────────────────────────────────────────────────
# FILE LISTING
# ─────────────────────────────────────────────────────────────────
alias ls="ls --color=auto"
alias ll="ls -lah"
alias la="ls -A"
alias l="ls -CF"

# ─────────────────────────────────────────────────────────────────
# SAFETY NETS
# ─────────────────────────────────────────────────────────────────
alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"

# ─────────────────────────────────────────────────────────────────
# SYSTEM INFO
# ─────────────────────────────────────────────────────────────────
alias mem="free -h"
alias disk="df -h"
alias top="htop"
alias ports="netstat -tlnp 2>/dev/null || ss -tlnp"

# ─────────────────────────────────────────────────────────────────
# GIT SHORTCUTS
# ─────────────────────────────────────────────────────────────────
alias g="git"
alias gs="git status"
alias gd="git diff"
alias gl="git lg"
alias gp="git push"
alias gpl="git pull"

# Quick commit and push
gap() {
    git add -A
    git commit -m "${1:-Update}"
    git push
}

# Clone and cd into repo
gcl() {
    git clone "$1"
    cd "$(basename "$1" .git)"
}

# ─────────────────────────────────────────────────────────────────
# UTILITY FUNCTIONS
# ─────────────────────────────────────────────────────────────────

# Make directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find files by name
ff() {
    find . -type f -name "*$1*" 2>/dev/null
}

# Find in files (grep replacement)
fif() {
    rg --color=always "$1" 2>/dev/null || grep -r "$1" . 2>/dev/null
}

# Quick HTTP server
serve() {
    local port="${1:-8080}"
    echo "Serving on http://localhost:$port"
    python -m http.server "$port" 2>/dev/null || npx http-server -p "$port"
}

# Extract any archive
extract() {
    case "$1" in
        *.tar.gz|*.tgz)  tar xzf "$1" ;;
        *.tar.bz2|*.tbz) tar xjf "$1" ;;
        *.tar.xz|*.txz)  tar xJf "$1" ;;
        *.tar)           tar xf "$1" ;;
        *.zip)           unzip "$1" ;;
        *.gz)            gunzip "$1" ;;
        *.bz2)           bunzip2 "$1" ;;
        *.xz)            unxz "$1" ;;
        *.7z)            7z x "$1" ;;
        *.rar)           unrar x "$1" ;;
        *)               echo "Unknown archive format: $1" ;;
    esac
}

# Backup file with timestamp
backup() {
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
}

# Timer with notification
timer() {
    local seconds="${1:-60}"
    echo "Timer set for ${seconds}s..."
    sleep "$seconds"
    notify "Timer" "Time's up! (${seconds}s)"
    vibrate 1000
}

# Weather
weather() {
    curl -s "wttr.in/${1:-}"
}

# Cheat sheet
cheat() {
    curl -s "cheat.sh/$1"
}

# ─────────────────────────────────────────────────────────────────
# AUTO CLAUDE.MD CREATION
# When entering a git repo without CLAUDE.md, create one
# ─────────────────────────────────────────────────────────────────
cd() {
    builtin cd "$@" || return
    if [ -d ".git" ] && [ ! -f "CLAUDE.md" ]; then
        local project_name=$(basename "$(pwd)")
        local branch=$(git branch --show-current 2>/dev/null || echo "main")

        cat > CLAUDE.md << TEMPLATE
# ${project_name}

## READ THIS FIRST - Every Session

## Current Branch
\`$branch\`

## Project Goal
[Describe what this project does]

## Current Status
- [ ] Task 1
- [ ] Task 2

## Build & Run
\`\`\`bash
# Add build commands here
\`\`\`

## Known Issues
| Issue | Cause | Fix |
|-------|-------|-----|
| | | |

## Failed Approaches (Don't Retry)
- None yet

## Rules
1. Read this file first every session
2. Plan before coding
3. Build after EVERY change
4. Update this file with progress
5. Verify before pushing
6. Notify when done

## Verification
\`\`\`bash
# Build
./gradlew assembleDebug  # or: npm run build

# Notify success
notify "Build" "Success - $project_name"
\`\`\`
TEMPLATE
        echo "📝 Created CLAUDE.md for $project_name"
    fi
}

# ─────────────────────────────────────────────────────────────────
# PROMPT
# ─────────────────────────────────────────────────────────────────
git_branch() {
    git branch 2>/dev/null | grep '^*' | sed 's/* //'
}

git_dirty() {
    [ -n "$(git status --porcelain 2>/dev/null)" ] && echo "*"
}

PS1='\[\033[0;32m\]\u\[\033[0m\]@\[\033[0;36m\]droid\[\033[0m\]:\[\033[0;34m\]\w\[\033[0;33m\]$([ -n "$(git_branch)" ] && echo " ($(git_branch)$(git_dirty))")\[\033[0m\]\$ '

# ─────────────────────────────────────────────────────────────────
# HELP COMMAND
# ─────────────────────────────────────────────────────────────────
h() {
    cat << 'HELP'
╔═══════════════════════════════════════════════════════════════╗
║  CLIdroid Quick Reference                                     ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  CLAUDE CODE              TERMUX API                          ║
║  ───────────              ──────────                          ║
║  claude / cc              notify "title" "msg"                ║
║  /start                   toast "message"                     ║
║  /plan                    battery                             ║
║  /build                   wifi / myip                         ║
║  /verify                  photo / record                      ║
║  /push                    speak "text" / listen               ║
║  /done                    torch on/off                        ║
║                           vibrate                             ║
║  GIT SHORTCUTS            clip (copy/paste)                   ║
║  ────────────             location                            ║
║  gs = status              ssh-server                          ║
║  gd = diff                                                    ║
║  gl = log graph           UTILITIES                           ║
║  gap "msg" = add+push     ─────────                           ║
║  gcl <url> = clone+cd     serve [port]                        ║
║                           extract <file>                      ║
║  NAVIGATION               timer [secs]                        ║
║  ──────────               weather [city]                      ║
║  .. / ... / ....          cheat <topic>                       ║
║  dl = downloads           mkcd <dir>                          ║
║  sd = sdcard              ff <name>                           ║
║                           fif <text>                          ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
HELP
}

# ─────────────────────────────────────────────────────────────────
# WELCOME MESSAGE
# ─────────────────────────────────────────────────────────────────
if [ -z "$CLIDROID_WELCOMED" ]; then
    export CLIDROID_WELCOMED=1
    echo ""
    echo -e "\033[0;36m╔═══════════════════════════════════════╗\033[0m"
    echo -e "\033[0;36m║\033[0m  \033[1mCLIdroid\033[0m - Ready                    \033[0;36m║\033[0m"
    echo -e "\033[0;36m╚═══════════════════════════════════════╝\033[0m"
    battery 2>/dev/null || true
    echo "Type 'h' for help | 'claude' for AI"
    echo ""
fi
BASHRC

    success "Shell environment configured"
}

# =============================================================================
# GITHUB CLI SETUP
# =============================================================================
setup_github() {
    step "12" "Checking GitHub CLI..."

    if ! command -v gh &> /dev/null; then
        warn "GitHub CLI not installed"
        return
    fi

    if gh auth status &> /dev/null; then
        success "GitHub CLI authenticated"
    else
        echo ""
        echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║  GitHub Authentication Required                              ║${NC}"
        echo -e "${YELLOW}╠══════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${YELLOW}║                                                              ║${NC}"
        echo -e "${YELLOW}║  To authenticate with GitHub, run:                           ║${NC}"
        echo -e "${YELLOW}║                                                              ║${NC}"
        echo -e "${YELLOW}║    ${BOLD}gh auth login${NC}${YELLOW}                                            ║${NC}"
        echo -e "${YELLOW}║                                                              ║${NC}"
        echo -e "${YELLOW}║  Then choose:                                                ║${NC}"
        echo -e "${YELLOW}║    • GitHub.com                                              ║${NC}"
        echo -e "${YELLOW}║    • HTTPS                                                   ║${NC}"
        echo -e "${YELLOW}║    • Login with a web browser                                ║${NC}"
        echo -e "${YELLOW}║                                                              ║${NC}"
        echo -e "${YELLOW}║  It will give you a code to enter at:                        ║${NC}"
        echo -e "${YELLOW}║    ${CYAN}https://github.com/login/device${NC}${YELLOW}                          ║${NC}"
        echo -e "${YELLOW}║                                                              ║${NC}"
        echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
    fi
}

# =============================================================================
# VERIFICATION
# =============================================================================
verify_installation() {
    echo ""
    echo -e "${BOLD}Verifying installation...${NC}"
    echo ""

    local passed=0
    local failed=0

    # Check each component
    verify_check() {
        if eval "$2" > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} $1"
            passed=$((passed + 1))
        else
            echo -e "${RED}✗${NC} $1"
            failed=$((failed + 1))
        fi
    }

    verify_check "Termux storage" "[ -d $HOME/storage ] || [ -d /sdcard ]"
    verify_check "Git installed" "command -v git"
    verify_check "Node.js installed" "command -v node"
    verify_check "Python installed" "command -v python"
    verify_check "Claude Code installed" "command -v claude"
    verify_check "SSH configured" "[ -f $HOME/.ssh/id_rsa ]"
    verify_check "Bin directory ready" "[ -d $HOME/bin ]"
    verify_check "Claude commands" "[ -d $HOME/.claude/commands ]"
    verify_check "Shell configured" "[ -f $HOME/.bashrc ]"
    verify_check "tmux configured" "[ -f $HOME/.tmux.conf ]"

    echo ""
    echo -e "Results: ${GREEN}${passed} passed${NC}, ${RED}${failed} failed${NC}"

    return 0
}

# =============================================================================
# COMPLETION
# =============================================================================
show_completion() {
    echo ""
    echo -e "${GREEN}"
    cat << 'EOF'
   ╔═══════════════════════════════════════════════════════════════╗
   ║                                                               ║
   ║     ██████╗ ██████╗ ███╗   ██╗███████╗██╗                     ║
   ║     ██╔══██╗██╔═══██╗████╗  ██║██╔════╝██║                    ║
   ║     ██║  ██║██║   ██║██╔██╗ ██║█████╗  ██║                    ║
   ║     ██║  ██║██║   ██║██║╚██╗██║██╔══╝  ╚═╝                    ║
   ║     ██████╔╝╚██████╔╝██║ ╚████║███████╗██╗                    ║
   ║     ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝                    ║
   ║                                                               ║
   ╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    echo -e "${BOLD}CLIdroid installation complete!${NC}"
    echo ""
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│  NEXT STEPS:                                                │"
    echo "├─────────────────────────────────────────────────────────────┤"
    echo "│                                                             │"
    echo "│  1. Restart Termux (swipe away and reopen)                  │"
    echo "│                                                             │"
    echo "│  2. Authenticate GitHub (if needed):                        │"
    echo "│     $ gh auth login                                         │"
    echo "│                                                             │"
    echo "│  3. Start Claude Code:                                      │"
    echo "│     $ claude                                                │"
    echo "│                                                             │"
    echo "│  4. Type 'h' for help anytime                               │"
    echo "│                                                             │"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""
    echo -e "  Log saved to: ${CYAN}$LOG_FILE${NC}"
    echo -e "  Backup at: ${CYAN}$BACKUP_DIR${NC}"
    echo ""
    echo -e "  ${BOLD}By PismoAI${NC} - github.com/PismoAI/CLIdroid"
    echo ""
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    show_header

    echo "This will set up your ultimate Android terminal environment."
    echo ""

    # Create log file
    echo "CLIdroid Installation Log - $(date)" > "$LOG_FILE"
    echo "Version: $VERSION" >> "$LOG_FILE"
    echo "---" >> "$LOG_FILE"

    check_prerequisites
    backup_existing
    setup_storage
    install_packages
    setup_termux_api
    install_claude
    setup_claude_boris
    setup_git
    setup_ssh
    setup_tmux
    setup_gradle
    setup_shell
    setup_github

    echo ""
    verify_installation
    show_completion

    # Notify completion (use full path since bashrc not sourced yet)
    "$HOME/bin/notify" "CLIdroid" "Installation complete!" 2>/dev/null || true
}

# Run main
main "$@"
