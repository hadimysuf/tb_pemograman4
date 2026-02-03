const db = require('../database/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

/**
 * REGISTER
 */
exports.register = (req, res) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ message: 'Semua field wajib diisi' });
  }

  const hashedPassword = bcrypt.hashSync(password, 10);

  try {
    db.prepare(
      'INSERT INTO users (name, email, password) VALUES (?, ?, ?)'
    ).run(name, email, hashedPassword);

    res.status(201).json({ message: 'Registrasi berhasil' });
  } catch (err) {
    if (err.code === 'SQLITE_CONSTRAINT_UNIQUE') {
      return res.status(400).json({ message: 'Email sudah terdaftar' });
    }
    res.status(500).json({ message: 'Server error' });
  }
};

/**
 * LOGIN
 */
exports.login = (req, res) => {
  const { email, password } = req.body;

  const user = db
    .prepare('SELECT * FROM users WHERE email = ?')
    .get(email);

  if (!user) {
    return res.status(401).json({ message: 'Email atau password salah' });
  }

  const isValid = bcrypt.compareSync(password, user.password);
  if (!isValid) {
    return res.status(401).json({ message: 'Email atau password salah' });
  }

  const token = jwt.sign(
    { id: user.id, email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: '1d' }
  );

  res.json({
    message: 'Login berhasil',
    token,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
    },
  });
};
