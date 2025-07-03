const express = require('express');
const { authenticateToken } = require('../middleware/auth');
const Chat = require('../models/chat');
const { pool } = require('../../config/db');

// Initialize model with pool
const chatModel = new Chat(pool);

const router = express.Router();

// Get user's group chats
router.get('/groups', authenticateToken, async (req, res) => {
  try {
    const groupChats = await chatModel.getGroupChats(req.user.userId);
    res.json({ groupChats });
  } catch (error) {
    console.error('Get group chats error:', error);
    res.status(500).json({ message: 'Failed to get group chats' });
  }
});

// Get group messages
router.get('/groups/:groupId/messages', authenticateToken, async (req, res) => {
  try {
    const { groupId } = req.params;
    
    // Check if user is member of the group
    const isMember = await chatModel.isUserInGroup(groupId, req.user.userId);
    if (!isMember) {
      return res.status(403).json({ message: 'Not a member of this group' });
    }
    
    const messages = await chatModel.getGroupMessages(groupId);
    res.json({ messages });
  } catch (error) {
    console.error('Get group messages error:', error);
    res.status(500).json({ message: 'Failed to get messages' });
  }
});

// Send message to group
router.post('/groups/:groupId/messages', authenticateToken, async (req, res) => {
  try {
    const { groupId } = req.params;
    const { message } = req.body;
    
    // Check if user is member of the group
    const isMember = await chatModel.isUserInGroup(groupId, req.user.userId);
    if (!isMember) {
      return res.status(403).json({ message: 'Not a member of this group' });
    }
    
    const newMessage = await chatModel.sendMessage(groupId, req.user.userId, message);
    
    // Emit to Socket.IO
    const io = req.app.get('io');
    io.to(groupId).emit('message', newMessage);
    
    res.json({ message: newMessage });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({ message: 'Failed to send message' });
  }
});

// Add member to group
router.post('/groups/:groupId/members', authenticateToken, async (req, res) => {
  try {
    const { groupId } = req.params;
    const { userId } = req.body;
    
    await chatModel.addMemberToGroup(groupId, userId);
    
    res.json({ message: 'Member added successfully' });
  } catch (error) {
    console.error('Add member error:', error);
    res.status(500).json({ message: 'Failed to add member' });
  }
});

// Remove member from group
router.delete('/groups/:groupId/members/:userId', authenticateToken, async (req, res) => {
  try {
    const { groupId, userId } = req.params;
    
    await chatModel.removeMemberFromGroup(groupId, userId);
    
    res.json({ message: 'Member removed successfully' });
  } catch (error) {
    console.error('Remove member error:', error);
    res.status(500).json({ message: 'Failed to remove member' });
  }
});

// Get group members
router.get('/groups/:groupId/members', authenticateToken, async (req, res) => {
  try {
    const { groupId } = req.params;
    
    // Check if user is member of the group
    const isMember = await chatModel.isUserInGroup(groupId, req.user.userId);
    if (!isMember) {
      return res.status(403).json({ message: 'Not a member of this group' });
    }
    
    const members = await chatModel.getGroupMembers(groupId);
    res.json({ members });
  } catch (error) {
    console.error('Get group members error:', error);
    res.status(500).json({ message: 'Failed to get members' });
  }
});

module.exports = router; 