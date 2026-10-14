const express = require('express');
const path = require('path');
const fs = require('fs');
const pool = require('./db');
const homeRouter = require('./routes/home');
const adminRouter = require('./routes/admin');
const { client, metricsMiddleware } = require('./metrics');

const app = express();
const port = Number(process.env.PORT || 3000);

// Setup log directory and file stream for Promtail / Loki
const logDir = process.env.LOG_DIR || '/var/log/app';
let logStream = null;
try {
  if (fs.existsSync(logDir)) {
    logStream = fs.createWriteStream(path.join(logDir, 'app.log'), { flags: 'a' });
  }
} catch (e) {
  console.error('Cannot initialize file log stream:', e.message);
}

function writeStructuredLog(data) {
  const record = {
    ...data,
    timestamp: new Date().toISOString()
  };
  const jsonLine = JSON.stringify(record);
  console.log(jsonLine);
  if (logStream) {
    try {
      logStream.write(jsonLine + '\n');
    } catch (_) {}
  }
}

app.disable('x-powered-by');
app.set('trust proxy', 1);

// View engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, '../views'));

// Middlewares
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static(path.join(__dirname, '../public')));

// Prometheus Metrics Middleware (Tiêu chí 4)
app.use(metricsMiddleware);

// Structured JSON Logging Middleware for Promtail / Loki (Tiêu chí 5)
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    if (req.path !== '/health' && req.path !== '/metrics' && req.path !== '/healthz') {
      const level = res.statusCode >= 500 ? 'error' : (res.statusCode >= 400 ? 'warn' : 'info');
      writeStructuredLog({
        level,
        event: 'http_request',
        method: req.method,
        path: req.path,
        status: res.statusCode,
        duration_ms: duration,
        ip: req.ip
      });
    }
  });
  next();
});

// Metrics endpoint for Prometheus (Tiêu chí 4)
app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', client.register.contentType);
    res.end(await client.register.metrics());
  } catch (error) {
    writeStructuredLog({
      level: 'error',
      event: 'metrics_error',
      message: error.message
    });
    res.status(500).send('Error collecting metrics');
  }
});

// Mount Routes
app.use('/', homeRouter);
app.use('/admin', adminRouter);

// Health check endpoint for Docker & Kubernetes
app.get('/health', async (req, res) => {
  try {
    await pool.execute('SELECT 1');
    res.json({
      status: 'ok',
      database: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    writeStructuredLog({
      level: 'error',
      event: 'health_check_failed',
      message: error.message
    });
    res.status(503).json({
      status: 'error',
      database: 'disconnected'
    });
  }
});

// 404 Handler
app.use((req, res) => {
  writeStructuredLog({
    level: 'warn',
    event: 'not_found',
    path: req.path,
    method: req.method,
    ip: req.ip,
    message: 'Page not found (404)'
  });
  res.status(404).send('Trang khong ton tai (404 Not Found). <a href="/">Quay lai trang chu</a>');
});

// Global Error Handler (500)
app.use((err, req, res, next) => {
  writeStructuredLog({
    level: 'error',
    event: 'internal_server_error',
    path: req.path,
    method: req.method,
    error: err.message,
    stack: err.stack
  });
  res.status(500).send('Loi he thong noi bo (500 Internal Server Error).');
});

app.listen(port, '0.0.0.0', () => {
  writeStructuredLog({
    level: 'info',
    event: 'server_started',
    port,
    message: `Titan Fitness Web Application running on port ${port}`
  });
});