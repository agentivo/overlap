const http = require('http');
const fs = require('fs');
const path = require('path');
const Gun = require('gun');

const port = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  // Health check
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('ok');
    return;
  }

  // Serve index.html for all non-gun requests
  if (!req.url.startsWith('/gun')) {
    const html = fs.readFileSync(path.join(__dirname, 'index.html'), 'utf8');
    res.writeHead(200, {
      'Content-Type': 'text/html',
      'Cache-Control': 'no-cache'
    });
    res.end(html);
    return;
  }
});

// Create Gun instance with persistence
const gun = Gun({ web: server, radisk: true });

// Wait for Gun to load data from disk before accepting connections
// This prevents race conditions where clients write before data is restored
console.log('Waiting for Gun to load data from disk...');

const startTime = Date.now();
const maxWait = 10000; // 10 seconds max

function startServer() {
  server.listen(port, () => {
    const loadTime = Date.now() - startTime;
    console.log(`Gun data loaded in ${loadTime}ms`);
    console.log(`Overlap running on port ${port}`);
    console.log(`Gun relay active at /gun`);
  });
}

// Trigger a read to force radisk to load, then start server
gun.get('overlap-events').once((data) => {
  if (!server.listening) {
    startServer();
  }
});

// Fallback timeout in case there's no data yet (new deployment)
setTimeout(() => {
  if (!server.listening) {
    console.log('No existing data found, starting server...');
    startServer();
  }
}, maxWait);
