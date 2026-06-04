#!/bin/bash

# Blue Bricks — Vibe Coding Workshop (interactief deel)
# Dit script draait wanneer je een terminal opent in de Codespace.
# Het vraagt om je workshopcode + naam en haalt je API key op.
# Wordt aangeroepen vanuit ~/.bashrc (één keer, daarna staat de vlag ~/.workshop-setup-done).

KEY_SERVICE_URL="https://unskillful-stompingly-cleora.ngrok-free.dev"
DONE_FLAG="$HOME/.workshop-setup-done"

# Kleuren
BLUE='\033[0;34m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

clear
echo ""
echo -e "${BLUE}██████╗ ██╗     ██╗   ██╗███████╗${NC}"
echo -e "${BLUE}██╔══██╗██║     ██║   ██║██╔════╝${NC}"
echo -e "${BLUE}██████╔╝██║     ██║   ██║█████╗  ${NC}"
echo -e "${BLUE}██╔══██╗██║     ██║   ██║██╔══╝  ${NC}"
echo -e "${BLUE}██████╔╝███████╗╚██████╔╝███████╗${NC}"
echo -e "${BLUE}╚═════╝ ╚══════╝ ╚═════╝ ╚══════╝${NC}"
echo -e "${BLUE}██████╗ ██████╗ ██╗ ██████╗██╗  ██╗███████╗${NC}"
echo -e "${BLUE}██╔══██╗██╔══██╗██║██╔════╝██║ ██╔╝██╔════╝${NC}"
echo -e "${BLUE}██████╔╝██████╔╝██║██║     █████╔╝ ███████╗${NC}"
echo -e "${BLUE}██╔══██╗██╔══██╗██║██║     ██╔═██╗ ╚════██║${NC}"
echo -e "${BLUE}██████╔╝██║  ██║██║╚██████╗██║  ██╗███████║${NC}"
echo -e "${BLUE}╚═════╝ ╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝${NC}"
echo ""
echo -e "  ${BOLD}Vibe Coding Workshop${NC}"
echo -e "  ${DIM}─────────────────────${NC}"
echo ""

# Vraag input
read -p "$(echo -e "${CYAN}?${NC}") Voer je workshopcode in: " WORKSHOP_CODE
read -p "$(echo -e "${CYAN}?${NC}") Voer je naam in: " PARTICIPANT_NAME

echo ""

# Validatie
if [ -z "$WORKSHOP_CODE" ] || [ -z "$PARTICIPANT_NAME" ]; then
  echo -e "  ${RED}✗ Workshopcode en naam zijn verplicht.${NC}"
  echo -e "  Probeer opnieuw met: ${BOLD}bash workshop-init.sh${NC}"
  echo ""
  exit 1
fi

# Haal configuratie op van de key vending service
echo -e "  ${DIM}Verbinden met workshop service...${NC}"

RESPONSE=$(curl -s -X POST "$KEY_SERVICE_URL/api/claim-key" \
  -H "Content-Type: application/json" \
  -H "ngrok-skip-browser-warning: 1" \
  -d "{\"workshopCode\": \"$WORKSHOP_CODE\", \"participantName\": \"$PARTICIPANT_NAME\"}")

# Check of curl gelukt is
if [ $? -ne 0 ] || [ -z "$RESPONSE" ]; then
  echo ""
  echo -e "  ${YELLOW}⚠️  Kan de workshop service niet bereiken.${NC}"
  echo ""
  echo -e "  Mogelijke oorzaken:"
  echo -e "  ${DIM}• De workshopleider heeft de service nog niet gestart${NC}"
  echo -e "  ${DIM}• Je hebt geen internetverbinding${NC}"
  echo ""
  echo -e "  Probeer opnieuw met: ${BOLD}bash workshop-init.sh${NC}"
  echo ""
  exit 1
fi

# Check voor errors in de response
ERROR=$(echo "$RESPONSE" | jq -r '.error // empty')
if [ -n "$ERROR" ]; then
  echo ""
  echo -e "  ${YELLOW}⚠️  $ERROR${NC}"
  echo ""
  echo -e "  Probeer opnieuw met: ${BOLD}bash workshop-init.sh${NC}"
  echo ""
  exit 1
fi

# Check API key
API_KEY=$(echo "$RESPONSE" | jq -r '.apiKey // empty')
if [ -z "$API_KEY" ]; then
  echo ""
  echo -e "  ${YELLOW}⚠️  Geen API key ontvangen.${NC}"
  echo ""
  echo -e "  Probeer opnieuw met: ${BOLD}bash workshop-init.sh${NC}"
  echo ""
  exit 1
fi

# === CONFIGURATIE STARTEN ===

# 1. API key opslaan in een apart env-bestand.
#    De ~/.bashrc-hook (zie setup.sh) sourcet dit bestand, zodat de key zowel in
#    DEZE terminal (direct na dit script) als in elke nieuwe terminal beschikbaar is.
echo "export ANTHROPIC_API_KEY='$API_KEY'" > "$HOME/.workshop-env"
export ANTHROPIC_API_KEY="$API_KEY"

# 1b. Claude Code vooraf configureren zodat er geen prompts verschijnen:
#     - hasCompletedOnboarding: slaat de thema-/welkomstkeuze over
#     - customApiKeyResponses.approved: keurt deze API key vooraf goed
#       (waarde = laatste 20 tekens van de key; ongedocumenteerd maar dit is hoe
#       Claude Code de goedkeuring onthoudt). Mislukt dit, dan zie je hooguit
#       eenmalig de "gebruik deze API key?"-popup — niet kritiek.
mkdir -p "$HOME/.claude"
KEY_SUFFIX="${API_KEY: -20}"
CLAUDE_JSON="$HOME/.claude.json"
if command -v jq >/dev/null 2>&1; then
  if [ -f "$CLAUDE_JSON" ]; then
    TMP_JSON="$(mktemp)"
    jq --arg s "$KEY_SUFFIX" '
      .hasCompletedOnboarding = true
      | .customApiKeyResponses.approved = (((.customApiKeyResponses.approved // []) + [$s]) | unique)
      | .customApiKeyResponses.rejected = (.customApiKeyResponses.rejected // [])
    ' "$CLAUDE_JSON" > "$TMP_JSON" 2>/dev/null && mv "$TMP_JSON" "$CLAUDE_JSON"
  else
    jq -n --arg s "$KEY_SUFFIX" '
      { hasCompletedOnboarding: true,
        customApiKeyResponses: { approved: [$s], rejected: [] } }
    ' > "$CLAUDE_JSON"
  fi
fi

# Haal config op
STACK=$(echo "$RESPONSE" | jq -r '.config.stack // "onbekend"')
TEMPLATE=$(echo "$RESPONSE" | jq -r '.config.template // "onbekend"')
STACK_NAME="$STACK"
START_CMD=$(echo "$RESPONSE" | jq -r '.config.startCommand // empty')

echo -e "  ⚙️  Stack: ${BOLD}$STACK_NAME${NC}"
echo -e "  📋 Template: ${BOLD}$TEMPLATE${NC}"
echo ""

# 2. Bestanden wegschrijven
echo -e "  ${DIM}Bestanden configureren...${NC}"
FILE_COUNT=$(echo "$RESPONSE" | jq -r '.config.files | length')

if [ "$FILE_COUNT" -gt 0 ]; then
  echo "$RESPONSE" | jq -r '.config.files | to_entries[] | @base64' | while read -r entry; do
    FILENAME=$(echo "$entry" | base64 -d | jq -r '.key')
    CONTENT=$(echo "$entry" | base64 -d | jq -r '.value')

    # Maak directory aan als nodig
    DIRNAME=$(dirname "$FILENAME")
    if [ "$DIRNAME" != "." ]; then
      mkdir -p "$DIRNAME"
    fi

    echo "$CONTENT" > "$FILENAME"
    echo -e "     ${GREEN}✓${NC} $FILENAME"
  done
fi

# 3. Packages installeren
PACKAGES=$(echo "$RESPONSE" | jq -r '.config.packages // [] | join(" ")')
DEV_PACKAGES=$(echo "$RESPONSE" | jq -r '.config.devDependencies // [] | join(" ")')

if [ -n "$PACKAGES" ] && [ "$PACKAGES" != "" ]; then
  echo ""
  echo -e "  📦 Packages installeren..."
  npm install $PACKAGES --silent 2>/dev/null
  echo -e "     ${GREEN}✓ $PACKAGES${NC}"
fi

if [ -n "$DEV_PACKAGES" ] && [ "$DEV_PACKAGES" != "" ]; then
  npm install -D $DEV_PACKAGES --silent 2>/dev/null
  echo -e "     ${GREEN}✓ $DEV_PACKAGES${NC} ${DIM}(dev)${NC}"
fi

# 4. Dev-server starten
if [ -n "$START_CMD" ]; then
  echo ""
  echo -e "  🚀 ${GREEN}Dev-server starten...${NC}"
  $START_CMD &>/dev/null &
  sleep 2
  echo -e "     ${GREEN}✓ Server draait${NC}"
fi

# === KLAAR ===

# Markeer als voltooid zodat dit script niet opnieuw vraagt bij elke nieuwe terminal.
touch "$DONE_FLAG"

echo ""
echo -e "  ${DIM}────────────────────────────────────${NC}"
echo -e "  ${GREEN}${BOLD}✅ Alles is klaar!${NC}"
echo ""
echo -e "  Je kunt nu direct beginnen — typ:"
echo ""
echo -e "     ${BOLD}claude${NC}"
echo ""

# Check of er INSTRUCTIONS.md is
if [ -f "INSTRUCTIONS.md" ]; then
  echo -e "  Lees ${BOLD}INSTRUCTIONS.md${NC} voor je eerste opdracht."
fi

echo -e "  Veel plezier met bouwen! 🧱"
echo -e "  ${DIM}────────────────────────────────────${NC}"
echo ""

# Laad de zojuist opgeslagen ANTHROPIC_API_KEY in deze shell-sessie.
export ANTHROPIC_API_KEY="$API_KEY"
