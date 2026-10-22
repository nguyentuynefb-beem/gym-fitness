const client = require('prom-client');

// Collect standard Node.js runtime metrics (Memory, CPU, Event loop, GC)
client.collectDefaultMetrics({
  prefix: 'gym_app_',
  timeout: 5000
});

// Custom HTTP Metrics
const httpRequestDurationSeconds = new client.Histogram({
  name: 'gym_http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2, 5]
});

const httpRequestsTotal = new client.Counter({
  name: 'gym_http_requests_total',
  help: 'Total number of HTTP requests processed',
  labelNames: ['method', 'route', 'status_code']
});

const activeHttpRequests = new client.Gauge({
  name: 'gym_active_http_requests',
  help: 'Number of currently active HTTP requests'
});

// Middleware to track HTTP metrics
function metricsMiddleware(req, res, next) {
  if (req.path === '/metrics' || req.path === '/health' || req.path === '/healthz') {
    return next();
  }

  activeHttpRequests.inc();
  const start = process.hrtime();

  res.on('finish', () => {
    activeHttpRequests.dec();

    const diff = process.hrtime(start);
    const durationSeconds = diff[0] + diff[1] / 1e9;

    let route = req.route ? req.baseUrl + req.route.path : req.baseUrl || req.path;
    if (!route || route === '') route = req.path || '/';

    const statusCode = res.statusCode ? res.statusCode.toString() : '500';

    httpRequestDurationSeconds.observe(
      { method: req.method, route, status_code: statusCode },
      durationSeconds
    );

    httpRequestsTotal.inc({
      method: req.method,
      route,
      status_code: statusCode
    });
  });

  next();
}

module.exports = {
  client,
  metricsMiddleware,
  httpRequestDurationSeconds,
  httpRequestsTotal,
  activeHttpRequests
};