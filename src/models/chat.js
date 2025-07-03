const db = require('../../config/db');

const Chat = {
  createGroup: async (name) => {
    const [result] = await db.execute('INSERT INTO group_chats (name) VALUES (?)', [name]);
    return result.insertId;
  },
  addMember: async (group_id, user_id) => {
    await db.execute('INSERT IGNORE INTO group_members (group_id, user_id) VALUES (?, ?)', [group_id, user_id]);
  },
  getUserGroups: async (user_id) => {
    const [rows] = await db.execute(
      `SELECT gc.* FROM group_chats gc
       JOIN group_members gm ON gc.id = gm.group_id
       WHERE gm.user_id = ?`, [user_id]);
    return rows;
  },
  saveMessage: async (group_id, sender_id, content) => {
    const [result] = await db.execute(
      'INSERT INTO messages (group_id, sender_id, content) VALUES (?, ?, ?)',
      [group_id, sender_id, content]
    );
    return result.insertId;
  },
  getMessages: async (group_id) => {
    const [rows] = await db.execute(
      `SELECT m.*, u.name as sender_name FROM messages m
       JOIN users u ON m.sender_id = u.id
       WHERE m.group_id = ? ORDER BY m.timestamp ASC`, [group_id]);
    return rows;
  }
};

module.exports = Chat; 