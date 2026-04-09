#!/bin/bash

# Blue Bricks — Vibe Coding Workshop Setup
# Dit script draait automatisch bij het openen van een Codespace.

KEY_SERVICE_URL="https://unskillful-stompingly-cleora.ngrok-free.dev"

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
  echo -e "  Probeer opnieuw met: ${BOLD}bash setup.sh${NC}"
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
  echo -e "  Mogelijke oorzassen:"
  echo -e "  ${DIM}• De workshopleider heeft de service nog niet gestart${NC}"
  echo -e "  ${DIM}• Je hebt geen internetverbinding${NC}"
  echo ""
  echo -e "  Probeer opnieuw met: ${BOLD}bash setup.sh${NC}"
  echo ""
  exit 1
fi

# Check voor errors in de response
ERROR=$(echo "$RESPONSE" | jq -r '.error // empty')
if [ -n "$ERROR" ]; then
  echo ""
  echo -e "  ${YELLOW}⚠️  $ERROR${NC}"
  echo ""
  echo -e "  Probeer opnieuw met: ${BOLD}bash setup.sh${NC}"
  echo ""
  exit 1
fi

# Check API key
API_KEY=$(echo "$RESPONSE" | jq -r '.apiKey // empty')
if [ -z "$API_KEY" ]; then
  echo ""
  echo -e "  ${YELLOW}⚠️  Geen API key ontvangen.${NC}"
  echo ""
  echo -e "  Probeer opnieuw met: ${BOLD}bash setup.sh${NC}"
  echo ""
  exit 1
fi

# === CONFIGURATIE STARTEN ===

# 1. API key opslaan
echo "export ANTHROPIC_API_KEY=$API_KEY" >> ~/.bashrc
export ANTHROPIC_API_KEY="$API_KEY"

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

echo ""
echo -e "  ${DIM}────────────────────────────────────${NC}"
echo -e "  ${GREEN}${BOLD}✅ Alles is klaar!${NC}"
echo ""
echo -e "  Open een nieuwe terminal en typ:"
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
