const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/', async (req, res) => {
  try {
    const [packages] = await pool.execute(
      'SELECT * FROM packages WHERE is_active = 1 ORDER BY price ASC'
    );

    const [trainers] = await pool.execute(
      "SELECT * FROM trainers WHERE status = 'active' ORDER BY experience_years DESC"
    );

    const [[memberStats]] = await pool.execute(
      "SELECT COUNT(*) as total FROM members WHERE status = 'active'"
    );

    const [schedules] = await pool.execute(`
      SELECT s.id, s.session_date, s.time_slot, s.workout_type, s.status, s.notes,
             t.full_name as trainer_name, t.specialty as trainer_specialty, t.avatar_url as trainer_avatar
      FROM schedules s
      LEFT JOIN trainers t ON s.trainer_id = t.id
      WHERE s.status = 'scheduled'
      ORDER BY s.session_date ASC, s.time_slot ASC
      LIMIT 8
    `);

    const stats = {
      activeMembers: memberStats.total || 0,
      totalTrainers: trainers.length,
      totalPackages: packages.length
    };

    res.render('index', {
      packages,
      trainers,
      schedules,
      stats,
      query: req.query
    });
  } catch (error) {
    console.error(JSON.stringify({
      level: 'error',
      event: 'home_page_error',
      message: error.message
    }));
    res.status(500).send('Lỗi máy chủ khi tải trang chủ. Vui lòng thử lại sau.');
  }
});

router.post('/register-trial', async (req, res) => {
  const { full_name, phone, email, package_id, notes } = req.body;

  if (!full_name || !phone) {
    return res.redirect('/?error=missing_fields#trial-form');
  }

  try {
    const pkgId = package_id ? Number(package_id) : null;
    const now = new Date();
    const startDate = now.toISOString().split('T')[0];
    const end = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
    const endDate = end.toISOString().split('T')[0];

    await pool.execute(
      "INSERT INTO members (full_name, phone, email, gender, package_id, start_date, end_date, status, notes) VALUES (?, ?, ?, 'other', ?, ?, ?, 'pending', ?)",
      [full_name.trim(), phone.trim(), email ? email.trim() : null, pkgId, startDate, endDate, notes || 'Đăng ký tập thử trực tuyến từ Website']
    );

    res.redirect('/?registered=1#trial-form');
  } catch (error) {
    console.error(JSON.stringify({
      level: 'error',
      event: 'trial_registration_error',
      message: error.message
    }));

    if (error.code === 'ER_DUP_ENTRY') {
      return res.redirect('/?error=duplicate_phone#trial-form');
    }
    res.redirect('/?error=system_error#trial-form');
  }
});

module.exports = router;
