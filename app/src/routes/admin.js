const express = require('express');
const router = express.Router();
const pool = require('../db');

// --- 1. DASHBOARD OVERVIEW ---
router.get('/', async (req, res) => {
  try {
    const [[memberStats]] = await pool.execute(
      "SELECT COUNT(*) AS total, SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) AS active, SUM(CASE WHEN status = 'expired' THEN 1 ELSE 0 END) AS expired, SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending FROM members"
    );

    const [[pkgStats]] = await pool.execute('SELECT COUNT(*) AS total FROM packages');
    const [[trainerStats]] = await pool.execute('SELECT COUNT(*) AS total FROM trainers');
    const [[schedStats]] = await pool.execute('SELECT COUNT(*) AS total FROM schedules WHERE session_date >= CURDATE()');

    const [recentMembers] = await pool.execute(
      "SELECT m.*, p.name AS package_name FROM members m LEFT JOIN packages p ON m.package_id = p.id ORDER BY m.created_at DESC LIMIT 5"
    );

    const [todaySchedules] = await pool.execute(
      "SELECT s.*, m.full_name AS member_name, t.full_name AS trainer_name FROM schedules s JOIN members m ON s.member_id = m.id LEFT JOIN trainers t ON s.trainer_id = t.id WHERE s.session_date = CURDATE() ORDER BY s.time_slot ASC LIMIT 5"
    );

    res.render('admin/dashboard', {
      stats: {
        totalMembers: memberStats.total || 0,
        activeMembers: memberStats.active || 0,
        expiredMembers: memberStats.expired || 0,
        pendingMembers: memberStats.pending || 0,
        totalPackages: pkgStats.total || 0,
        totalTrainers: trainerStats.total || 0,
        upcomingSchedules: schedStats.total || 0
      },
      recentMembers,
      todaySchedules,
      activeMenu: 'dashboard'
    });
  } catch (error) {
    console.error('Admin Dashboard Error:', error);
    res.status(500).send('Lỗi khi tải bảng điều khiển.');
  }
});

// --- 2. MEMBERS CRUD ---
router.get('/members', async (req, res) => {
  const { q, status } = req.query;
  try {
    let sql = "SELECT m.*, p.name AS package_name FROM members m LEFT JOIN packages p ON m.package_id = p.id WHERE 1=1";
    const params = [];

    if (q) {
      sql += ' AND (m.full_name LIKE ? OR m.phone LIKE ? OR m.email LIKE ?)';
      const term = '%' + q.trim() + '%';
      params.push(term, term, term);
    }

    if (status && ['active', 'expired', 'pending'].includes(status)) {
      sql += ' AND m.status = ?';
      params.push(status);
    }

    sql += ' ORDER BY m.id DESC';
    const [members] = await pool.execute(sql, params);
    const [packages] = await pool.execute('SELECT id, name FROM packages WHERE is_active = 1');

    res.render('admin/members', {
      members,
      packages,
      searchQuery: q || '',
      selectedStatus: status || '',
      activeMenu: 'members',
      msg: req.query.msg || ''
    });
  } catch (error) {
    console.error('Admin Members Error:', error);
    res.status(500).send('Lỗi khi tải danh sách hội viên.');
  }
});

router.post('/members/add', async (req, res) => {
  const { full_name, phone, email, gender, package_id, start_date, end_date, status, notes } = req.body;
  try {
    await pool.execute(
      "INSERT INTO members (full_name, phone, email, gender, package_id, start_date, end_date, status, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [full_name, phone, email || null, gender || 'other', package_id || null, start_date, end_date, status || 'active', notes || '']
    );
    res.redirect('/admin/members?msg=added');
  } catch (error) {
    console.error('Add Member Error:', error);
    res.redirect('/admin/members?msg=error');
  }
});

router.post('/members/edit/:id', async (req, res) => {
  const { id } = req.params;
  const { full_name, phone, email, gender, package_id, start_date, end_date, status, notes } = req.body;
  try {
    await pool.execute(
      "UPDATE members SET full_name = ?, phone = ?, email = ?, gender = ?, package_id = ?, start_date = ?, end_date = ?, status = ?, notes = ? WHERE id = ?",
      [full_name, phone, email || null, gender, package_id || null, start_date, end_date, status, notes, id]
    );
    res.redirect('/admin/members?msg=updated');
  } catch (error) {
    console.error('Update Member Error:', error);
    res.redirect('/admin/members?msg=error');
  }
});

router.post('/members/delete/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.execute('DELETE FROM members WHERE id = ?', [id]);
    res.redirect('/admin/members?msg=deleted');
  } catch (error) {
    console.error('Delete Member Error:', error);
    res.redirect('/admin/members?msg=error');
  }
});

// --- 3. PACKAGES CRUD ---
router.get('/packages', async (req, res) => {
  try {
    const [packages] = await pool.execute('SELECT * FROM packages ORDER BY id DESC');
    res.render('admin/packages', {
      packages,
      activeMenu: 'packages',
      msg: req.query.msg || ''
    });
  } catch (error) {
    console.error('Admin Packages Error:', error);
    res.status(500).send('Lỗi khi tải danh sách gói tập.');
  }
});

router.post('/packages/add', async (req, res) => {
  const { name, category, duration_months, price, description, features } = req.body;
  try {
    await pool.execute(
      "INSERT INTO packages (name, category, duration_months, price, description, features) VALUES (?, ?, ?, ?, ?, ?)",
      [name, category || 'Gym', Number(duration_months || 1), Number(price || 0), description || '', features || '']
    );
    res.redirect('/admin/packages?msg=added');
  } catch (error) {
    console.error('Add Package Error:', error);
    res.redirect('/admin/packages?msg=error');
  }
});

router.post('/packages/edit/:id', async (req, res) => {
  const { id } = req.params;
  const { name, category, duration_months, price, description, features, is_active } = req.body;
  try {
    await pool.execute(
      "UPDATE packages SET name = ?, category = ?, duration_months = ?, price = ?, description = ?, features = ?, is_active = ? WHERE id = ?",
      [name, category, Number(duration_months), Number(price), description, features, is_active ? 1 : 0, id]
    );
    res.redirect('/admin/packages?msg=updated');
  } catch (error) {
    console.error('Update Package Error:', error);
    res.redirect('/admin/packages?msg=error');
  }
});

router.post('/packages/delete/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.execute('DELETE FROM packages WHERE id = ?', [id]);
    res.redirect('/admin/packages?msg=deleted');
  } catch (error) {
    console.error('Delete Package Error:', error);
    res.redirect('/admin/packages?msg=error');
  }
});

// --- 4. TRAINERS CRUD ---
router.get('/trainers', async (req, res) => {
  try {
    const [trainers] = await pool.execute('SELECT * FROM trainers ORDER BY id DESC');
    res.render('admin/trainers', {
      trainers,
      activeMenu: 'trainers',
      msg: req.query.msg || ''
    });
  } catch (error) {
    console.error('Admin Trainers Error:', error);
    res.status(500).send('Lỗi khi tải danh sách huấn luyện viên.');
  }
});

router.post('/trainers/add', async (req, res) => {
  const { full_name, phone, email, specialty, experience_years, bio, status } = req.body;
  try {
    await pool.execute(
      "INSERT INTO trainers (full_name, phone, email, specialty, experience_years, bio, status) VALUES (?, ?, ?, ?, ?, ?, ?)",
      [full_name, phone, email || null, specialty, Number(experience_years || 1), bio || '', status || 'active']
    );
    res.redirect('/admin/trainers?msg=added');
  } catch (error) {
    console.error('Add Trainer Error:', error);
    res.redirect('/admin/trainers?msg=error');
  }
});

router.post('/trainers/edit/:id', async (req, res) => {
  const { id } = req.params;
  const { full_name, phone, email, specialty, experience_years, bio, status } = req.body;
  try {
    await pool.execute(
      "UPDATE trainers SET full_name = ?, phone = ?, email = ?, specialty = ?, experience_years = ?, bio = ?, status = ? WHERE id = ?",
      [full_name, phone, email || null, specialty, Number(experience_years), bio, status, id]
    );
    res.redirect('/admin/trainers?msg=updated');
  } catch (error) {
    console.error('Update Trainer Error:', error);
    res.redirect('/admin/trainers?msg=error');
  }
});

router.post('/trainers/delete/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.execute('DELETE FROM trainers WHERE id = ?', [id]);
    res.redirect('/admin/trainers?msg=deleted');
  } catch (error) {
    console.error('Delete Trainer Error:', error);
    res.redirect('/admin/trainers?msg=error');
  }
});

// --- 5. SCHEDULES CRUD ---
router.get('/schedules', async (req, res) => {
  try {
    const [schedules] = await pool.execute(
      "SELECT s.*, m.full_name AS member_name, m.phone AS member_phone, t.full_name AS trainer_name FROM schedules s JOIN members m ON s.member_id = m.id LEFT JOIN trainers t ON s.trainer_id = t.id ORDER BY s.session_date DESC, s.time_slot ASC"
    );

    const [members] = await pool.execute("SELECT id, full_name, phone FROM members WHERE status != 'expired' ORDER BY full_name ASC");
    const [trainers] = await pool.execute("SELECT id, full_name, specialty FROM trainers WHERE status = 'active' ORDER BY full_name ASC");

    res.render('admin/schedules', {
      schedules,
      members,
      trainers,
      activeMenu: 'schedules',
      msg: req.query.msg || ''
    });
  } catch (error) {
    console.error('Admin Schedules Error:', error);
    res.status(500).send('Lỗi khi tải lịch tập.');
  }
});

router.post('/schedules/add', async (req, res) => {
  const { member_id, trainer_id, session_date, time_slot, workout_type, notes } = req.body;
  try {
    await pool.execute(
      "INSERT INTO schedules (member_id, trainer_id, session_date, time_slot, workout_type, status, notes) VALUES (?, ?, ?, ?, ?, 'scheduled', ?)",
      [member_id, trainer_id || null, session_date, time_slot, workout_type || 'Tập cá nhân', notes || '']
    );
    res.redirect('/admin/schedules?msg=added');
  } catch (error) {
    console.error('Add Schedule Error:', error);
    res.redirect('/admin/schedules?msg=error');
  }
});

router.post('/schedules/status/:id', async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  try {
    await pool.execute('UPDATE schedules SET status = ? WHERE id = ?', [status, id]);
    res.redirect('/admin/schedules?msg=updated');
  } catch (error) {
    console.error('Update Schedule Status Error:', error);
    res.redirect('/admin/schedules?msg=error');
  }
});

router.post('/schedules/delete/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.execute('DELETE FROM schedules WHERE id = ?', [id]);
    res.redirect('/admin/schedules?msg=deleted');
  } catch (error) {
    console.error('Delete Schedule Error:', error);
    res.redirect('/admin/schedules?msg=error');
  }
});

module.exports = router;
