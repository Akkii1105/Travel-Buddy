const mysql = require('mysql2/promise');

class Chat {
  constructor(pool) {
    this.pool = pool;
  }

  async createGroupChat(tripId, name) {
    const [result] = await this.pool.execute(
      'INSERT INTO group_chats (trip_id, name) VALUES (?, ?)',
      [tripId, name]
    );
    return result.insertId;
  }

  async getGroupChats(userId) {
    const [rows] = await this.pool.execute(`
      SELECT gc.*, t.title as trip_title, t.destination,
             COUNT(gm.user_id) as member_count,
             (SELECT COUNT(*) FROM group_messages gm2 WHERE gm2.group_id = gc.id) as message_count
      FROM group_chats gc
      JOIN trips t ON gc.trip_id = t.id
      JOIN trip_members tm ON t.id = tm.trip_id
      LEFT JOIN group_members gm ON gc.id = gm.group_id
      WHERE tm.user_id = ? OR t.creator_id = ?
      GROUP BY gc.id
      ORDER BY gc.created_at DESC
    `, [userId, userId]);
    return rows;
  }

  async getGroupMessages(groupId) {
    const [rows] = await this.pool.execute(`
      SELECT gm.*, u.name as sender_name, u.college as sender_college
      FROM group_messages gm
      JOIN users u ON gm.sender_id = u.id
      WHERE gm.group_id = ?
      ORDER BY gm.created_at ASC
    `, [groupId]);
    return rows;
  }

  async sendMessage(groupId, senderId, message) {
    const [result] = await this.pool.execute(
      'INSERT INTO group_messages (group_id, sender_id, message) VALUES (?, ?, ?)',
      [groupId, senderId, message]
    );
    
    // Get the created message with sender info
    const [rows] = await this.pool.execute(`
      SELECT gm.*, u.name as sender_name, u.college as sender_college
      FROM group_messages gm
      JOIN users u ON gm.sender_id = u.id
      WHERE gm.id = ?
    `, [result.insertId]);
    
    return rows[0];
  }

  async addMemberToGroup(groupId, userId) {
    await this.pool.execute(
      'INSERT INTO group_members (group_id, user_id) VALUES (?, ?)',
      [groupId, userId]
    );
  }

  async removeMemberFromGroup(groupId, userId) {
    await this.pool.execute(
      'DELETE FROM group_members WHERE group_id = ? AND user_id = ?',
      [groupId, userId]
    );
  }

  async getGroupMembers(groupId) {
    const [rows] = await this.pool.execute(`
      SELECT u.id, u.name, u.email, u.college
      FROM group_members gm
      JOIN users u ON gm.user_id = u.id
      WHERE gm.group_id = ?
    `, [groupId]);
    return rows;
  }

  async isUserInGroup(groupId, userId) {
    const [rows] = await this.pool.execute(
      'SELECT * FROM group_members WHERE group_id = ? AND user_id = ?',
      [groupId, userId]
    );
    return rows.length > 0;
  }

  async getGroupChatByTripId(tripId) {
    const [rows] = await this.pool.execute(
      'SELECT * FROM group_chats WHERE trip_id = ?',
      [tripId]
    );
    return rows[0];
  }
}

module.exports = Chat; 