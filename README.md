# Vibe Coding Workshop

Welkom! Dit is je werkplek voor de workshop. Nog nooit geprogrammeerd? Geen zorgen — alles staat al voor je klaar en Claude doet het zware werk. 🧱

## Eerst even: wat is dit allemaal?

Een paar woorden die je vandaag tegenkomt, in gewone taal:

- **GitHub** — een soort online opslagplek én samenwerkplek voor code. Denk aan *Google Drive, maar dan voor programmeurs*. Jouw code en jouw werkplek staan hier veilig in je eigen account.
- **Codespace** — een **complete computer in de cloud**, die gewoon in je browser draait. Je hoeft niks op je eigen laptop te installeren: alles (inclusief Claude) staat al geïnstalleerd. Wat je hier maakt, blijft van jou.
- **De terminal** — het venster (vaak onderin) waar je **tekstcommando's** typt. Hier "praat" je met de computer én met Claude. Je typt iets en drukt op **Enter**. Meer is het niet.

## Aan de slag

Toen je deze Codespace opende, is de omgeving automatisch klaargezet (o.a. Claude Code geïnstalleerd). Het laatste stukje gebeurt in de terminal:

1. Open een **nieuwe terminal** (Ctrl+` of Terminal → New Terminal)
2. De **workshopvragen verschijnen automatisch** — voer je **workshopcode** en **naam** in
3. Zodra je een ✅ ziet, typ je `claude` en druk je op Enter
4. Beschrijf wat je wilt bouwen — Claude helpt je!

> Zie je de vragen niet automatisch? Typ dan `bash workshop-init.sh` in de terminal.

## Hulp nodig?

- **Workshopvragen opnieuw beantwoorden**: typ `bash workshop-init.sh` in de terminal
- **Hele setup opnieuw draaien**: typ `bash setup.sh` in de terminal
- **Instructies bekijken**: open `INSTRUCTIONS.md` (als die er is)
- **Vraag je workshopleider** als je er niet uitkomt

## Je werk opslaan

Je Codespace en je code blijven in jouw GitHub-account staan, maar het is slim om je werk apart op te slaan in een eigen project:

1. Klik op het **Source Control** icoon in de zijbalk (of druk Ctrl+Shift+G)
2. Klik op **Publish Branch**
3. Kies **Publish to GitHub private repository**
4. Geef je repo een naam
5. Klaar — je code staat nu veilig op jouw GitHub!

---

## 🏠 Thuis verder werken (na de workshop)

Leuk dat je verder wilt! Een paar dingen om te weten:

- Je **Codespace blijft bestaan** in je GitHub-account. Je opent 'm later weer via **[github.com/codespaces](https://github.com/codespaces)**.
- Codespaces zijn een aantal uur per maand gratis; daarna kan het (een beetje) geld kosten. Zorg er dus voor dat je je code hebt opgeslagen (zie *Je werk opslaan* hierboven).
- **De workshop-toegang (API-key) wordt na de workshop uitgezet.** Dat is normaal. Om verder te kunnen, koppel je je *eigen* account. Hieronder lees je hoe — kies de optie die bij jou past.

### Optie A — Met een Claude-account (makkelijkst)

Je werkte tijdens de workshop al met Claude, dus dit sluit het beste aan.

1. Open de terminal en verwijder de oude workshop-sleutel:
   ```bash
   rm ~/.workshop-env
   ```
2. **Sluit de terminal en open een nieuwe** (zodat de oude sleutel niet meer wordt geladen).
3. Typ:
   ```bash
   claude
   ```
4. Claude vraagt je nu om in te loggen — log in met je **Claude-account**.

> Je hebt hiervoor een betaald **Claude Pro**- of **Max**-abonnement nodig (het gratis Claude-account werkt niet met Claude Code). Bekijk de actuele opties op **[claude.com/pricing](https://claude.com/pricing)**.

### Optie B — Met je eigen Anthropic API-key (betalen per gebruik)

Liever betalen per gebruik in plaats van een abonnement?

1. Haal een eigen sleutel op via **[console.anthropic.com](https://console.anthropic.com)** → *API Keys* → *Create Key* (en kopieer 'm).
2. Zet je eigen sleutel klaar (vervang `sk-ant-JOUW-KEY` door je echte sleutel):
   ```bash
   echo 'export ANTHROPIC_API_KEY="sk-ant-JOUW-KEY"' > ~/.workshop-env
   ```
3. **Open een nieuwe terminal** en typ `claude`. Klaar!

> Bij deze optie betaal je per gebruik. Je verbruik zie je op **[console.anthropic.com](https://console.anthropic.com)**.

### Optie C — Met een ChatGPT-account

Heb je geen Claude, maar wél een **ChatGPT-account**? Dan kun je verder met **Codex**, het terminal-gereedschap van OpenAI (vergelijkbaar met Claude Code, maar dan met ChatGPT).

1. Installeer Codex in de terminal:
   ```bash
   curl -fsSL https://chatgpt.com/codex/install.sh | sh
   ```
2. Start het:
   ```bash
   codex
   ```
3. Log in met je **ChatGPT-account** (er opent een browservenster).

> Codex werkt met de meeste ChatGPT-abonnementen (Free, Plus, Pro, e.a.). Meer info: **[developers.openai.com/codex](https://developers.openai.com/codex/cli)**.
>
> Let op: Codex is een ander programma dan Claude. De Claude-instellingen uit deze workshop gelden er niet voor — je typt `codex` in plaats van `claude`.

---

Veel plezier met bouwen! 🚀
