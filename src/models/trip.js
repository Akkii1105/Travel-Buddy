const db = require('../../config/db');

const Trip = {
  create: async ({ user_id, source, destination, start_time, end_time, status }) => {
    const [result] = await db.execute(
      'INSERT INTO trips (user_id, source, destination, start_time, end_time, status) VALUES (?, ?, ?, ?, ?, ?)',
      [user_id, source, destination, start_time, end_time, status || 'active']
    );
    return result.insertId;
  },

  listByUser: async (user_id) => {
    const [rows] = await db.execute('SELECT * FROM trips WHERE user_id = ? ORDER BY start_time DESC', [user_id]);
    return rows;
  },

  cancel: async (trip_id, user_id) => {
    await db.execute('UPDATE trips SET status = ? WHERE id = ? AND user_id = ?', ['cancelled', trip_id, user_id]);
  },

  findMatching: async ({ college, source, destination, start_time, end_time }) => {
    // Find trips with same college, source, destination, and overlapping time
    const [rows] = await db.execute(
      `SELECT t.*, u.college FROM trips t
       JOIN users u ON t.user_id = u.id
       WHERE u.college = ?
         AND t.source = ?
         AND t.destination = ?
         AND t.status = 'active'
         AND ((t.start_time <= ? AND t.end_time >= ?) OR (t.start_time <= ? AND t.end_time >= ?))`,
      [college, source, destination, end_time, end_time, start_time, start_time]
    );
    return rows;
  },
};

module.exports = Trip; 