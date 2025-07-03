const db = require('../../travelbuddy-backend/config/db');

const User = {
  create: async ({ name, email, password, college, avatar, location }) => {
    const [result] = await db.execute(
      'INSERT INTO users (name, email, password, college, avatar, location) VALUES (?, ?, ?, ?, ?, ?)',
      [name, email, password, college, avatar, location]
    );
    return result.insertId;
  },

  findByEmail: async (email) => {
    const [rows] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
    return rows[0];
  },

  findById: async (id) => {
    const [rows] = await db.execute('SELECT * FROM users WHERE id = ?', [id]);
    return rows[0];
  },

  updateProfile: async (id, { name, college, avatar, location }) => {
    await db.execute(
      'UPDATE users SET name = ?, college = ?, avatar = ?, location = ? WHERE id = ?',
      [name, college, avatar, location, id]
    );
  },
};

module.exports = User; 