const db = require('../database/db');

/**
 * CREATE EVENT
 */
exports.createEvent = (req, res) => {
  const { title, date, startTime, endTime, image } = req.body;

  if (!title || !date || !startTime || !endTime) {
    return res.status(400).json({ message: 'Field wajib belum lengkap' });
  }

  db.prepare(`
    INSERT INTO events (title, date, startTime, endTime, image, userId)
    VALUES (?, ?, ?, ?, ?, ?)
  `).run(
    title,
    date,
    startTime,
    endTime,
    image || null,
    req.user.id
  );

  res.status(201).json({ message: 'Event berhasil dibuat' });
};

/**
 * GET ALL EVENTS (user login)
 */
exports.getEvents = (req, res) => {
  const events = db.prepare(`
    SELECT * FROM events
    WHERE userId = ?
    ORDER BY date ASC, startTime ASC
  `).all(req.user.id);

  res.json(events);
};

/**
 * GET EVENT DETAIL
 */
exports.getEventById = (req, res) => {
  const event = db.prepare(`
    SELECT * FROM events
    WHERE id = ? AND userId = ?
  `).get(req.params.id, req.user.id);

  if (!event) {
    return res.status(404).json({ message: 'Event tidak ditemukan' });
  }

  res.json(event);
};

/**
 * UPDATE EVENT
 */
exports.updateEvent = (req, res) => {
  const { title, date, startTime, endTime, image } = req.body;

  const result = db.prepare(`
    UPDATE events
    SET title = ?, date = ?, startTime = ?, endTime = ?, image = ?
    WHERE id = ? AND userId = ?
  `).run(
    title,
    date,
    startTime,
    endTime,
    image || null,
    req.params.id,
    req.user.id
  );

  if (result.changes === 0) {
    return res.status(404).json({ message: 'Event tidak ditemukan' });
  }

  res.json({ message: 'Event berhasil diupdate' });
};

/**
 * DELETE EVENT
 */
/**
 * DELETE EVENT
 */
exports.deleteEvent = (req, res) => {
  const { id } = req.params;

  const result = db.prepare(`
    DELETE FROM events
    WHERE id = ?
  `).run(id);

  if (result.changes === 0) {
    return res.status(404).json({ message: 'Event tidak ditemukan' });
  }

  res.json({ message: 'Event berhasil dihapus' });
};

