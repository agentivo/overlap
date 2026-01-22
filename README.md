# Overlap

Find a time that works for everyone. Real-time group availability scheduling without accounts or calendar integrations.

## How it works

1. Visit the app and mark when you're free (click and drag)
2. Share the link with your group
3. See overlapping availability in Group view
4. Copy the times that work for everyone

## Features

- Real-time sync across participants
- 15-minute time slot granularity
- Timezone awareness
- Light/dark theme
- No accounts required

## Self-hosting

Requires Node.js 18+.

```bash
npm install
node server.js
```

The server runs on port 3000 by default (configurable via `PORT` env var). Data persists via Gun.js.

For production, use the included GitHub Actions workflow with Cloudflare Tunnel.

## Stack

- Single-file frontend (vanilla JS)
- Gun.js for real-time P2P data sync
- Node.js server as Gun relay
