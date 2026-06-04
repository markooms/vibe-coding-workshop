#!/bin/bash

# Blue Bricks — Vibe Coding Workshop Setup (build-stap)
# Dit script draait AUTOMATISCH en NIET-INTERACTIEF bij het bouwen van de Codespace
# (via postCreateCommand in .devcontainer/devcontainer.json).
#
# Het vraagt bewust NIETS: lifecycle-hooks van een devcontainer hebben geen
# interactieve terminal, dus 'read' werkt hier niet. Daarom doen we hier alleen
# het zware, niet-interactieve werk (dependencies + Claude Code installeren) en
# registreren we een hook in ~/.bashrc die het interactieve deel (workshop-init.sh)
# afvuurt zodra de deelnemer een terminal opent.

set -e

# Absoluut pad naar deze repo (robuust, ongeacht waar de Codespace 'm mount).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INIT_SCRIPT="$SCRIPT_DIR/workshop-init.sh"

echo "▶ Workshop build-stap gestart..."

# 1. Claude Code CLI installeren (zodat 'claude' meteen beschikbaar is in de terminal)
if ! command -v claude >/dev/null 2>&1; then
  echo "  • Claude Code CLI installeren..."
  npm install -g @anthropic-ai/claude-code >/dev/null 2>&1 || \
    echo "  ⚠️  Kon Claude Code CLI niet globaal installeren (gaat mogelijk via de VS Code-extensie)."
else
  echo "  • Claude Code CLI is al aanwezig."
fi

# 2. jq controleren (nodig in workshop-init.sh voor het verwerken van de config-response)
if ! command -v jq >/dev/null 2>&1; then
  echo "  • jq installeren..."
  sudo apt-get update -qq >/dev/null 2>&1 && sudo apt-get install -y -qq jq >/dev/null 2>&1 || \
    echo "  ⚠️  Kon jq niet installeren."
fi

# 3. workshop-init.sh uitvoerbaar maken
chmod +x "$INIT_SCRIPT" 2>/dev/null || true

# 4. Hook registreren in ~/.bashrc: draai workshop-init.sh één keer in de eerste
#    interactieve terminal. Beschermd door:
#    - interactieve shell-check ([[ $- == *i* ]])
#    - vlag-bestand ~/.workshop-setup-done (gezet door workshop-init.sh bij succes)
HOOK_MARKER="# >>> vibe-workshop init hook >>>"
if ! grep -q "$HOOK_MARKER" ~/.bashrc 2>/dev/null; then
  {
    echo ""
    echo "$HOOK_MARKER"
    echo "if [[ \$- == *i* ]] && [ ! -f \"\$HOME/.workshop-setup-done\" ]; then"
    echo "  bash \"$INIT_SCRIPT\""
    echo "fi"
    echo "# Laad de API key in DEZE shell (direct na init) en in elke nieuwe terminal."
    echo "[ -f \"\$HOME/.workshop-env\" ] && source \"\$HOME/.workshop-env\""
    echo "# <<< vibe-workshop init hook <<<"
  } >> ~/.bashrc
  echo "  • Terminal-hook geregistreerd in ~/.bashrc"
fi

echo "✓ Build-stap klaar. De workshopvragen verschijnen zodra de deelnemer een terminal opent."
