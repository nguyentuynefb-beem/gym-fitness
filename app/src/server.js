const express = require('express');
const mysql = require('mysql2/promise');
const path = require('path');

const app = express();
const port = Number(process.env.PORT || 3000);

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 5,
  connectTimeout: 5000
});

app.disable('x-powered-by');
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, '../views'));

app.get('/', async (req, res) => {
  try {
    const [rows] = await pool.execute(
      'SELECT COUNT(*) AS total FROM members'
    );

    res.render('index', {
      memberCount: rows[0].total
    });
  } catch (error) {
    console.error(JSON.stringify({
      level: 'error',
      event: 'homepage_database_error',
      code: error.code || 'UNKNOWN'
    }));

    res.status(503).send(
      'Chưa kết nối được cơ sở dữ liệu. Hãy kiểm tra log.'
    );
  }
});

app.get('/health', async (req, res) => {
  try {
    await pool.execute('SELECT 1');

    res.json({
      status: 'ok',
      database: 'connected'
    });
  } catch (error) {
    console.error(JSON.stringify({
      level: 'error',
      event: 'health_database_error',
      code: error.code || 'UNKNOWN'
    }));

    res.status(503).json({
      status: 'error',
      database: 'unavailable'
    });
  }
});

app.listen(port, '0.0.0.0', () => {
  console.log(JSON.stringify({
    level: 'info',
    event: 'server_started',
    port
  }));
});