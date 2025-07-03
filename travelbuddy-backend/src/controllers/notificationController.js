const pool = require('../config/db');
const admin = require('firebase-admin');

// Initialize Firebase Admin (you'll need to add your service account key)
// const serviceAccount = require('../config/firebase-service-account.json');
// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount)
// });

// Register device token for push notifications
const registerDeviceToken = async (req, res) => {
  try {
    const { deviceToken, platform = 'android' } = req.body;
    const userId = req.user.userId;

    // Check if token already exists for this user
    const [existing] = await pool.execute(
      'SELECT * FROM device_tokens WHERE user_id = ? AND device_token = ?',
      [userId, deviceToken]
    );

    if (existing.length > 0) {
      return res.json({ message: 'Device token already registered' });
    }

    // Register new device token
    await pool.execute(
      'INSERT INTO device_tokens (user_id, device_token, platform) VALUES (?, ?, ?)',
      [userId, deviceToken, platform]
    );

    res.json({ message: 'Device token registered successfully' });
  } catch (error) {
    console.error('Register device token error:', error);
    res.status(500).json({ message: 'Failed to register device token' });
  }
};

// Get user's notifications
const getNotifications = async (req, res) => {
  try {
    const userId = req.user.userId;

    const [notifications] = await pool.execute(`
      SELECT n.*, u.name as sender_name
      FROM notifications n
      LEFT JOIN users u ON n.sender_id = u.id
      WHERE n.recipient_id = ?
      ORDER BY n.created_at DESC
      LIMIT 50
    `, [userId]);

    res.json({ notifications });
  } catch (error) {
    console.error('Get notifications error:', error);
    res.status(500).json({ message: 'Failed to get notifications' });
  }
};

// Mark notification as read
const markNotificationAsRead = async (req, res) => {
  try {
    const { notificationId } = req.params;
    const userId = req.user.userId;

    // Verify notification belongs to user
    const [notifications] = await pool.execute(
      'SELECT * FROM notifications WHERE id = ? AND recipient_id = ?',
      [notificationId, userId]
    );

    if (notifications.length === 0) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    // Mark as read
    await pool.execute(
      'UPDATE notifications SET is_read = 1 WHERE id = ?',
      [notificationId]
    );

    res.json({ message: 'Notification marked as read' });
  } catch (error) {
    console.error('Mark notification as read error:', error);
    res.status(500).json({ message: 'Failed to mark notification as read' });
  }
};

// Send push notification to user
const sendPushNotification = async (userId, title, body, data = {}) => {
  try {
    // Get user's device tokens
    const [tokens] = await pool.execute(
      'SELECT device_token, platform FROM device_tokens WHERE user_id = ?',
      [userId]
    );

    if (tokens.length === 0) {
      console.log(`No device tokens found for user ${userId}`);
      return;
    }

    // Prepare notification payload
    const message = {
      notification: {
        title,
        body,
      },
      data: {
        ...data,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      tokens: tokens.map(token => token.device_token),
    };

    // Send notification via Firebase
    // const response = await admin.messaging().sendMulticast(message);
    console.log(`Push notification sent to user ${userId}:`, message);

    // Log notification in database
    await pool.execute(
      'INSERT INTO notifications (recipient_id, title, body, data) VALUES (?, ?, ?, ?)',
      [userId, title, body, JSON.stringify(data)]
    );

  } catch (error) {
    console.error('Send push notification error:', error);
  }
};

// Send notification to trip participants
const sendTripNotification = async (tripId, title, body, data = {}) => {
  try {
    // Get all participants of the trip
    const [participants] = await pool.execute(
      'SELECT user_id FROM trip_participants WHERE trip_id = ?',
      [tripId]
    );

    // Send notification to each participant
    for (const participant of participants) {
      await sendPushNotification(participant.user_id, title, body, {
        ...data,
        tripId: tripId.toString(),
      });
    }
  } catch (error) {
    console.error('Send trip notification error:', error);
  }
};

// Send notification to group chat members
const sendGroupNotification = async (groupId, title, body, data = {}) => {
  try {
    // Get all members of the group
    const [members] = await pool.execute(
      'SELECT user_id FROM group_chat_members WHERE group_id = ?',
      [groupId]
    );

    // Send notification to each member
    for (const member of members) {
      await sendPushNotification(member.user_id, title, body, {
        ...data,
        groupId: groupId.toString(),
      });
    }
  } catch (error) {
    console.error('Send group notification error:', error);
  }
};

// Delete device token
const deleteDeviceToken = async (req, res) => {
  try {
    const { deviceToken } = req.params;
    const userId = req.user.userId;

    await pool.execute(
      'DELETE FROM device_tokens WHERE user_id = ? AND device_token = ?',
      [userId, deviceToken]
    );

    res.json({ message: 'Device token deleted successfully' });
  } catch (error) {
    console.error('Delete device token error:', error);
    res.status(500).json({ message: 'Failed to delete device token' });
  }
};

// Get unread notification count
const getUnreadCount = async (req, res) => {
  try {
    const userId = req.user.userId;

    const [result] = await pool.execute(
      'SELECT COUNT(*) as count FROM notifications WHERE recipient_id = ? AND is_read = 0',
      [userId]
    );

    res.json({ unreadCount: result[0].count });
  } catch (error) {
    console.error('Get unread count error:', error);
    res.status(500).json({ message: 'Failed to get unread count' });
  }
};

module.exports = {
  registerDeviceToken,
  getNotifications,
  markNotificationAsRead,
  sendPushNotification,
  sendTripNotification,
  sendGroupNotification,
  deleteDeviceToken,
  getUnreadCount
}; 