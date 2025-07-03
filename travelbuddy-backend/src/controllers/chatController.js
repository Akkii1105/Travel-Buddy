const pool = require('../config/db');
const { sendGroupNotification } = require('./notificationController');

// Create a group chat for a trip
const createGroupChat = async (req, res) => {
  try {
    const { tripId, memberIds } = req.body;
    const creatorId = req.user.userId;

    // Verify trip exists and user is a participant
    const [trips] = await pool.execute(
      'SELECT * FROM trips WHERE id = ?',
      [tripId]
    );

    if (trips.length === 0) {
      return res.status(404).json({ message: 'Trip not found' });
    }

    // Check if group chat already exists for this trip
    const [existingGroups] = await pool.execute(
      'SELECT * FROM group_chats WHERE trip_id = ?',
      [tripId]
    );

    if (existingGroups.length > 0) {
      return res.status(400).json({ message: 'Group chat already exists for this trip' });
    }

    // Create group chat
    const [result] = await pool.execute(
      'INSERT INTO group_chats (trip_id, name) VALUES (?, ?)',
      [tripId, `Trip ${tripId} Chat`]
    );

    const groupId = result.insertId;

    // Add all members to the group
    const allMembers = [...new Set([creatorId, ...memberIds])];
    for (const memberId of allMembers) {
      await pool.execute(
        'INSERT INTO group_chat_members (group_id, user_id) VALUES (?, ?)',
        [groupId, memberId]
      );
    }

    res.status(201).json({
      message: 'Group chat created successfully',
      groupChat: {
        id: groupId,
        tripId,
        name: `Trip ${tripId} Chat`,
        members: allMembers
      }
    });
  } catch (error) {
    console.error('Create group chat error:', error);
    res.status(500).json({ message: 'Failed to create group chat' });
  }
};

// Get user's group chats
const getGroupChats = async (req, res) => {
  try {
    const userId = req.user.userId;

    const [groups] = await pool.execute(`
      SELECT gc.*, t.source, t.destination, t.departure_time,
             COUNT(gcm.user_id) as member_count,
             (SELECT COUNT(*) FROM messages m WHERE m.group_id = gc.id) as message_count
      FROM group_chats gc
      LEFT JOIN trips t ON gc.trip_id = t.id
      LEFT JOIN group_chat_members gcm ON gc.id = gcm.group_id
      WHERE gc.id IN (
        SELECT group_id FROM group_chat_members WHERE user_id = ?
      )
      GROUP BY gc.id
      ORDER BY gc.created_at DESC
    `, [userId]);

    res.json({ groupChats: groups });
  } catch (error) {
    console.error('Get group chats error:', error);
    res.status(500).json({ message: 'Failed to get group chats' });
  }
};

// Get messages for a group chat
const getGroupMessages = async (req, res) => {
  try {
    const { groupId } = req.params;
    const userId = req.user.userId;

    // Verify user is a member of the group
    const [members] = await pool.execute(
      'SELECT * FROM group_chat_members WHERE group_id = ? AND user_id = ?',
      [groupId, userId]
    );

    if (members.length === 0) {
      return res.status(403).json({ message: 'Not a member of this group' });
    }

    // Get messages with sender information
    const [messages] = await pool.execute(`
      SELECT m.*, u.name as sender_name, u.college as sender_college
      FROM messages m
      LEFT JOIN users u ON m.sender_id = u.id
      WHERE m.group_id = ?
      ORDER BY m.created_at ASC
    `, [groupId]);

    res.json({ messages });
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({ message: 'Failed to get messages' });
  }
};

// Send a message to group chat
const sendMessage = async (req, res) => {
  try {
    const { groupId } = req.params;
    const { content } = req.body;
    const senderId = req.user.userId;

    // Verify user is a member of the group
    const [members] = await pool.execute(
      'SELECT * FROM group_chat_members WHERE group_id = ? AND user_id = ?',
      [groupId, senderId]
    );

    if (members.length === 0) {
      return res.status(403).json({ message: 'Not a member of this group' });
    }

    // Save message to database
    const [result] = await pool.execute(
      'INSERT INTO messages (group_id, sender_id, content) VALUES (?, ?, ?)',
      [groupId, senderId, content]
    );

    // Get message with sender information
    const [messages] = await pool.execute(`
      SELECT m.*, u.name as sender_name, u.college as sender_college
      FROM messages m
      LEFT JOIN users u ON m.sender_id = u.id
      WHERE m.id = ?
    `, [result.insertId]);

    const message = messages[0];

    // Emit message to all group members via Socket.IO
    req.app.get('io').to(groupId.toString()).emit('message', {
      id: message.id,
      groupId: parseInt(groupId),
      senderId: message.sender_id,
      senderName: message.sender_name,
      content: message.content,
      createdAt: message.created_at
    });

    // Send push notification to all group members except sender
    const [groupMembers] = await pool.execute(
      'SELECT user_id FROM group_chat_members WHERE group_id = ?',
      [groupId]
    );
    for (const member of groupMembers) {
      if (member.user_id !== senderId) {
        sendGroupNotification(groupId, 'New Message', `You have a new message in your group chat.`);
      }
    }

    res.status(201).json({
      message: 'Message sent successfully',
      messageData: message
    });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({ message: 'Failed to send message' });
  }
};

// Add member to group chat
const addMemberToGroup = async (req, res) => {
  try {
    const { groupId } = req.params;
    const { userId } = req.body;
    const currentUserId = req.user.userId;

    // Verify current user is a member of the group
    const [members] = await pool.execute(
      'SELECT * FROM group_chat_members WHERE group_id = ? AND user_id = ?',
      [groupId, currentUserId]
    );

    if (members.length === 0) {
      return res.status(403).json({ message: 'Not a member of this group' });
    }

    // Check if user is already a member
    const [existing] = await pool.execute(
      'SELECT * FROM group_chat_members WHERE group_id = ? AND user_id = ?',
      [groupId, userId]
    );

    if (existing.length > 0) {
      return res.status(400).json({ message: 'User is already a member' });
    }

    // Add user to group
    await pool.execute(
      'INSERT INTO group_chat_members (group_id, user_id) VALUES (?, ?)',
      [groupId, userId]
    );

    res.json({ message: 'Member added successfully' });
  } catch (error) {
    console.error('Add member error:', error);
    res.status(500).json({ message: 'Failed to add member' });
  }
};

// Remove member from group chat
const removeMemberFromGroup = async (req, res) => {
  try {
    const { groupId, userId } = req.params;
    const currentUserId = req.user.userId;

    // Verify current user is a member of the group
    const [members] = await pool.execute(
      'SELECT * FROM group_chat_members WHERE group_id = ? AND user_id = ?',
      [groupId, currentUserId]
    );

    if (members.length === 0) {
      return res.status(403).json({ message: 'Not a member of this group' });
    }

    // Remove user from group
    await pool.execute(
      'DELETE FROM group_chat_members WHERE group_id = ? AND user_id = ?',
      [groupId, userId]
    );

    res.json({ message: 'Member removed successfully' });
  } catch (error) {
    console.error('Remove member error:', error);
    res.status(500).json({ message: 'Failed to remove member' });
  }
};

module.exports = {
  createGroupChat,
  getGroupChats,
  getGroupMessages,
  sendMessage,
  addMemberToGroup,
  removeMemberFromGroup
}; 