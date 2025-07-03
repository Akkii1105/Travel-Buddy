const express = require('express');
const router = express.Router();
const Chat = require('../models/chat');
const auth = require('../middleware/auth');

// Create a new group chat
router.post('/group', auth, async (req, res) => {
  try {
    const { name, userIds } = req.body; // userIds: array of user IDs to add
    const groupId = await Chat.createGroup(name);
    for (const uid of userIds) {
      await Chat.addMember(groupId, uid);
    }
    res.status(201).json({ groupId });
  } catch (err) {
    res.status(500).json({ message: 'Failed to create group', error: err.message });
  }
});

// Get all groups for the logged-in user
router.get('/groups', auth, async (req, res) => {
  try {
    const groups = await Chat.getUserGroups(req.user.id);
    res.json(groups);
  } catch (err) {
    res.status(500).json({ message: 'Failed to fetch groups', error: err.message });
  }
});

// Get all messages for a group
router.get('/messages/:groupId', auth, async (req, res) => {
  try {
    const messages = await Chat.getMessages(req.params.groupId);
    res.json(messages);
  } catch (err) {
    res.status(500).json({ message: 'Failed to fetch messages', error: err.message });
  }
});

module.exports = router; 