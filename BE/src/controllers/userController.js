const db = require('../database/db');
const bcrypt = require('bcryptjs');

const safeUser = (user) => {
  if (!user) return null;
  return {
    id: user.id,
    name: user.name,
    email: user.email,
  };
};

/**
 * GET ALL USERS
 */
exports.getUsers = (req, res) => {
  const users = db.prepare('SELECT id, name, email FROM users').all();
  res.json(users);
};

/**
 * GET USER BY ID
 */
exports.getUserById = (req, res) => {
  const user = db
    .prepare('SELECT id, name, email FROM users WHERE id = ?')
    .get(req.params.id);

  if (!user) {
    return res.status(404).json({ message: 'User tidak ditemukan' });
  }

  res.json(user);
};

/**
 * GET MY PROFILE
 */
exports.getMe = (req, res) => {
  const user = db
    .prepare('SELECT id, name, email FROM users WHERE id = ?')
    .get(req.user.id);

  if (!user) {
    return res.status(404).json({ message: 'User tidak ditemukan' });
  }

  res.json(user);
};

/**
 * UPDATE USER BY ID
 */
exports.updateUser = (req, res) => {
  const { name, email, password } = req.body;
  const user = db.prepare('SELECT * FROM users WHERE id = ?').get(req.params.id);

  if (!user) {
    return res.status(404).json({ message: 'User tidak ditemukan' });
  }

  const newName = name ?? user.name;
  const newEmail = email ?? user.email;
  const newPassword = password
    ? bcrypt.hashSync(password, 10)
    : user.password;

  try {
    const result = db
      .prepare('UPDATE users SET name = ?, email = ?, password = ? WHERE id = ?')
      .run(newName, newEmail, newPassword, req.params.id);

    if (result.changes === 0) {
      return res.status(400).json({ message: 'Tidak ada perubahan' });
    }

    res.json({ message: 'User berhasil diupdate' });
  } catch (err) {
    if (err.code === 'SQLITE_CONSTRAINT_UNIQUE') {
      return res.status(400).json({ message: 'Email sudah terdaftar' });
    }
    res.status(500).json({ message: 'Server error' });
  }
};

/**
 * UPDATE MY PROFILE
 */
exports.updateMe = (req, res) => {
  req.params.id = req.user.id;
  return exports.updateUser(req, res);
};

/**
 * CHANGE MY PASSWORD
 */
exports.changePassword = (req, res) => {
  const { oldPassword, newPassword } = req.body;

  if (!oldPassword || !newPassword) {
    return res.status(400).json({ message: 'Password lama dan baru wajib diisi' });
  }

  const user = db.prepare('SELECT * FROM users WHERE id = ?').get(req.user.id);
  if (!user) {
    return res.status(404).json({ message: 'User tidak ditemukan' });
  }

  const isValid = bcrypt.compareSync(oldPassword, user.password);
  if (!isValid) {
    return res.status(400).json({ message: 'Password lama salah' });
  }

  const hashed = bcrypt.hashSync(newPassword, 10);
  db.prepare('UPDATE users SET password = ? WHERE id = ?').run(hashed, req.user.id);

  res.json({ message: 'Password berhasil diubah' });
};

/**
 * DELETE USER BY ID
 */
exports.deleteUser = (req, res) => {
  const result = db
    .prepare('DELETE FROM users WHERE id = ?')
    .run(req.params.id);

  if (result.changes === 0) {
    return res.status(404).json({ message: 'User tidak ditemukan' });
  }

  res.json({ message: 'User berhasil dihapus' });
};

/**
 * DELETE MY ACCOUNT
 */
exports.deleteMe = (req, res) => {
  req.params.id = req.user.id;
  return exports.deleteUser(req, res);
};
