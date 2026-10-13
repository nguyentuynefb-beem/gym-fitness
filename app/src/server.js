const express = require('express');
const path = require('path');
const pool = require('./db');
const homeRouter = require('./routes/home');
const adminRouter = require('./routes/admin');

const app = express();
const port = Number(process.env.PORT || 3000);

app.disable('x-powered-by');

// View engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, '../views'));

// Middlewares
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static(path.join(__dirname, '../public')));

// Request logging (JSON formatted for Promtail/Loki)
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    if (req.path !== '/health') {
      console.log(JSON.stringify({
        level: 'info',
        event: 'http_request',
        method: req.method,
        path: req.path,
        status: res.statusCode,
        duration_ms: duration,
        ip: req.ip
      }));
    }
  });
  next();
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
    console.error(JSON.stringify({
      level: 'error',
      event: 'health_check_failed',
      message: error.message
    }));
    res.status(503).json({
      status: 'error',
      database: 'disconnected'
    });
  }
});

// 404 Handler
app.use((req, res) => {
  res.status(404).send('Trang khong ton tai (404 Not Found). <a href="/">Quay lai trang chu</a>');
});

app.listen(port, '0.0.0.0', () => {
  console.log(JSON.stringify({
    level: 'info',
    event: 'server_started',
    port
  }));
});