const express = require('express');
const cors = require('cors');
const { WebSocketServer } = require('ws');
const http = require('http');

const app = express();
const PORT = process.env.PORT || 3000;

// ─── Middleware ──────────────────────────────────────────────────────────
app.use(cors());
app.use(express.json());

// ─── Health Check ───────────────────────────────────────────────────────
app.get('/', (req, res) => {
  res.json({ status: 'ok', server: 'LG Starter Kit Node Server' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', uptime: process.uptime() });
});

// ─── API Routes ─────────────────────────────────────────────────────────

// Server status
app.get('/api/status', (req, res) => {
  res.json({
    success: true,
    server: 'LG Starter Kit Node Server',
    version: '1.0.0',
    uptime: `${Math.floor(process.uptime())}s`,
    endpoints: [
      'GET  /api/status',
      'POST /api/kml/generate',
      'GET  /api/data',
      'GET  /api/earthquakes',
    ],
  });
});

// KML Generation
app.post('/api/kml/generate', (req, res) => {
  const { type, lat, lng, name, description } = req.body;

  let kml = '';
  switch (type) {
    case 'placemark':
      kml = `<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>${name || 'Generated Placemark'}</name>
    <Placemark>
      <name>${name || 'Point'}</name>
      <description>${description || ''}</description>
      <Point>
        <coordinates>${lng || 0},${lat || 0},0</coordinates>
      </Point>
    </Placemark>
  </Document>
</kml>`;
      break;
    default:
      kml = `<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document><name>Empty</name></Document>
</kml>`;
  }

  res.json({ success: true, kml, message: 'KML generated successfully' });
});

// Sample data endpoint
app.get('/api/data', (req, res) => {
  res.json({
    success: true,
    data: [
      { name: 'Lleida', lat: 41.6176, lng: 0.6200, info: 'LG Lab HQ' },
      { name: 'Barcelona', lat: 41.3874, lng: 2.1686, info: 'Catalonia capital' },
      { name: 'Madrid', lat: 40.4168, lng: -3.7038, info: 'Spain capital' },
    ],
  });
});

// ─── WebSocket Server ───────────────────────────────────────────────────
const server = http.createServer(app);
const wss = new WebSocketServer({ server });

wss.on('connection', (ws) => {
  console.log('WebSocket client connected');

  ws.on('message', (message) => {
    console.log('Received:', message.toString());
    // Echo back with timestamp
    ws.send(JSON.stringify({
      echo: message.toString(),
      timestamp: new Date().toISOString(),
    }));
  });

  ws.on('close', () => {
    console.log('WebSocket client disconnected');
  });

  // Send welcome message
  ws.send(JSON.stringify({ type: 'welcome', message: 'Connected to LG Server' }));
});

// ─── Start Server ───────────────────────────────────────────────────────
server.listen(PORT, () => {
  console.log(`LG Starter Kit Server running on port ${PORT}`);
  console.log(`  HTTP: http://localhost:${PORT}`);
  console.log(`  WS:   ws://localhost:${PORT}`);
});
