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

// Attach Gun relay to the server
Gun({ web: server, radisk: true });

server.listen(port, () => {
  console.log(`Overlap running on port ${port}`);
  console.log(`Gun relay active at /gun`);
});
