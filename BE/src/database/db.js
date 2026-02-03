const Database = require('better-sqlite3');

// ⚠️ PATH RELATIF → DB ADA DI ROOT PROJECT
const db = new Database('event_app.db');

// USERS
db.prepare(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    email TEXT UNIQUE,
    password TEXT
  )
`).run();

// EVENTS
db.prepare(`
  CREATE TABLE IF NOT EXISTS events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    title TEXT,
    date TEXT,
    startTime TEXT,
    endTime TEXT,
    image TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
  )
`).run();

// Ensure new columns exist for older databases.
const eventColumns = db
  .prepare(`PRAGMA table_info(events)`)
  .all()
  .map((col) => col.name);

const addEventColumnIfMissing = (name, type) => {
  if (!eventColumns.includes(name)) {
    db.prepare(`ALTER TABLE events ADD COLUMN ${name} ${type}`).run();
  }
};

addEventColumnIfMissing('location', 'TEXT');
addEventColumnIfMissing('description', 'TEXT');

console.log('Database & tables ready ✅');

module.exports = db;
