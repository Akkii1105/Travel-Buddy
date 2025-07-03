const express = require('express');
const { authenticateToken } = require('../middleware/auth');
const Notification = require('../models/notification');
const { pool } = require('../../config/db');

// Initialize model with pool
const notificationModel = new Notification(pool);

const router = express.Router();

// Register device token for push notifications
router.post('/register', authenticateToken, async (req, res) => {
  try {
    const { deviceToken } = req.body;
    
    await notificationModel.registerDeviceToken(req.user.userId, deviceToken);
    
    res.json({ message: 'Device token registered successfully' });
  } catch (error) {
    console.error('Register device token error:', error);
    res.status(500).json({ message: 'Failed to register device token' });
  }
});

// Get user notifications
router.get('/', authenticateToken, async (req, res) => {
  try {
          const notifications = await notificationModel.getNotifications(req.user.userId);
    res.json({ notifications });
  } catch (error) {
    console.error('Get notifications error:', error);
    res.status(500).json({ message: 'Failed to get notifications' });
  }
});

// Mark notification as read
router.put('/:notificationId/read', authenticateToken, async (req, res) => {
  try {
    const { notificationId } = req.params;
    
    await notificationModel.markAsRead(notificationId);
    
    res.json({ message: 'Notification marked as read' });
  } catch (error) {
    console.error('Mark notification as read error:', error);
    res.status(500).json({ message: 'Failed to mark notification as read' });
  }
});

// Get unread notification count
router.get('/unread-count', authenticateToken, async (req, res) => {
  try {
    const count = await notificationModel.getUnreadCount(req.user.userId);
    res.json({ count });
  } catch (error) {
    console.error('Get unread count error:', error);
    res.status(500).json({ message: 'Failed to get unread count' });
  }
});

// Delete device token
router.delete('/tokens/:deviceToken', authenticateToken, async (req, res) => {
  try {
    const { deviceToken } = req.params;
    
    await notificationModel.deleteDeviceToken(deviceToken);
    
    res.json({ message: 'Device token deleted successfully' });
  } catch (error) {
    console.error('Delete device token error:', error);
    res.status(500).json({ message: 'Failed to delete device token' });
  }
});

module.exports = router; 