const mysql = require('mysql2/promise');

class Notification {
  constructor(pool) {
    this.pool = pool;
  }

  async registerDeviceToken(userId, deviceToken) {
    // Check if token already exists
    const [existing] = await this.pool.execute(
      'SELECT * FROM device_tokens WHERE user_id = ? AND token = ?',
      [userId, deviceToken]
    );

    if (existing.length === 0) {
      await this.pool.execute(
        'INSERT INTO device_tokens (user_id, token) VALUES (?, ?)',
        [userId, deviceToken]
      );
    }
  }

  async createNotification(userId, title, message, type, relatedId = null) {
    const [result] = await this.pool.execute(
      'INSERT INTO notifications (user_id, title, message, type, related_id) VALUES (?, ?, ?, ?, ?)',
      [userId, title, message, type, relatedId]
    );
    return result.insertId;
  }

  async getNotifications(userId) {
    const [rows] = await this.pool.execute(
      'SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC',
      [userId]
    );
    return rows;
  }

  async getUnreadCount(userId) {
    const [rows] = await this.pool.execute(
      'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = 0',
      [userId]
    );
    return rows[0].count;
  }

  async markAsRead(notificationId) {
    await this.pool.execute(
      'UPDATE notifications SET is_read = 1 WHERE id = ?',
      [notificationId]
    );
  }

  async deleteDeviceToken(deviceToken) {
    await this.pool.execute(
      'DELETE FROM device_tokens WHERE token = ?',
      [deviceToken]
    );
  }

  async getDeviceTokens(userId) {
    const [rows] = await this.pool.execute(
      'SELECT token FROM device_tokens WHERE user_id = ?',
      [userId]
    );
    return rows.map(row => row.token);
  }

  async createTripNotification(tripId, title, message, excludeUserId = null) {
    // Get all members of the trip
    let query = `
      SELECT DISTINCT u.id
      FROM users u
      JOIN trip_members tm ON u.id = tm.user_id
      WHERE tm.trip_id = ?
    `;
    let params = [tripId];

    if (excludeUserId) {
      query += ' AND u.id != ?';
      params.push(excludeUserId);
    }

    const [members] = await this.pool.execute(query, params);

    // Create notifications for all members
    for (const member of members) {
      await this.createNotification(member.id, title, message, 'trip', tripId);
    }
  }
}

module.exports = Notification; 