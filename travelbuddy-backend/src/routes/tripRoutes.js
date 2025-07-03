const express = require('express');
const { authenticateToken } = require('../middleware/auth');
const Trip = require('../models/trip');
const Chat = require('../models/chat');
const Notification = require('../models/notification');
const User = require('../models/user');
const { pool } = require('../../config/db');

// Initialize models with pool
const tripModel = new Trip(pool);
const chatModel = new Chat(pool);
const notificationModel = new Notification(pool);
const userModel = new User(pool);

const router = express.Router();

// Create a new trip
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { title, description, destination, startDate, endDate, maxMembers, budget, interests } = req.body;
    
    const tripId = await tripModel.create({
      title,
      description,
      destination,
      startDate,
      endDate,
      maxMembers,
      creatorId: req.user.userId,
      budget,
      interests
    });
    
    // Create group chat for the trip
    await chatModel.createGroupChat(tripId, `${title} Group Chat`);
    
    // Add creator as member
    await tripModel.addMember(tripId, req.user.userId);
    
    const trip = await tripModel.findById(tripId);
    
    res.json({
      message: 'Trip created successfully',
      trip
    });
  } catch (error) {
    console.error('Create trip error:', error);
    res.status(500).json({ message: 'Failed to create trip' });
  }
});

// Get all trips
router.get('/', authenticateToken, async (req, res) => {
  try {
    const trips = await tripModel.findAll();
    res.json({ trips });
  } catch (error) {
    console.error('Get trips error:', error);
    res.status(500).json({ message: 'Failed to get trips' });
  }
});

// Get user's trips
router.get('/my', authenticateToken, async (req, res) => {
  try {
    const trips = await tripModel.findUserTrips(req.user.userId);
    res.json({ trips });
  } catch (error) {
    console.error('Get my trips error:', error);
    res.status(500).json({ message: 'Failed to get trips' });
  }
});

// Get trip matches
router.get('/matches', authenticateToken, async (req, res) => {
  try {
    // Get user info for matching
    const user = await userModel.findById(req.user.userId);
    const trips = await tripModel.findMatches(req.user.userId, user.college, user.interests || '');
    res.json({ trips });
  } catch (error) {
    console.error('Get trip matches error:', error);
    res.status(500).json({ message: 'Failed to get trip matches' });
  }
});

// Get trip by ID
router.get('/:tripId', authenticateToken, async (req, res) => {
  try {
    const { tripId } = req.params;
    const trip = await tripModel.findById(tripId);
    
    if (!trip) {
      return res.status(404).json({ message: 'Trip not found' });
    }
    
    const members = await tripModel.getMembers(tripId);
    trip.members = members;
    
    res.json({ trip });
  } catch (error) {
    console.error('Get trip error:', error);
    res.status(500).json({ message: 'Failed to get trip' });
  }
});

// Join trip
router.post('/:tripId/join', authenticateToken, async (req, res) => {
  try {
    const { tripId } = req.params;
    const trip = await tripModel.findById(tripId);
    
    if (!trip) {
      return res.status(404).json({ message: 'Trip not found' });
    }
    
    if (trip.current_members >= trip.max_members) {
      return res.status(400).json({ message: 'Trip is full' });
    }
    
    await tripModel.addMember(tripId, req.user.userId);
    
    // Add user to group chat
    const groupChat = await chatModel.getGroupChatByTripId(tripId);
    if (groupChat) {
      await chatModel.addMemberToGroup(groupChat.id, req.user.userId);
    }
    
    // Send notification to trip creator
    await notificationModel.createNotification(
      trip.creator_id,
      'New Member Joined',
      `Someone joined your trip: ${trip.title}`,
      'trip',
      tripId
    );
    
    res.json({ message: 'Successfully joined trip' });
  } catch (error) {
    console.error('Join trip error:', error);
    res.status(500).json({ message: 'Failed to join trip' });
  }
});

// Leave trip
router.post('/:tripId/leave', authenticateToken, async (req, res) => {
  try {
    const { tripId } = req.params;
    
    await tripModel.removeMember(tripId, req.user.userId);
    
    // Remove user from group chat
    const groupChat = await chatModel.getGroupChatByTripId(tripId);
    if (groupChat) {
      await chatModel.removeMemberFromGroup(groupChat.id, req.user.userId);
    }
    
    res.json({ message: 'Successfully left trip' });
  } catch (error) {
    console.error('Leave trip error:', error);
    res.status(500).json({ message: 'Failed to leave trip' });
  }
});

// Cancel trip (creator only)
router.delete('/:tripId', authenticateToken, async (req, res) => {
  try {
    const { tripId } = req.params;
    const trip = await tripModel.findById(tripId);
    
    if (!trip) {
      return res.status(404).json({ message: 'Trip not found' });
    }
    
    if (trip.creator_id !== req.user.userId) {
      return res.status(403).json({ message: 'Only trip creator can cancel trip' });
    }
    
    await tripModel.delete(tripId);
    
    // Notify all members
    await notificationModel.createTripNotification(
      tripId,
      'Trip Cancelled',
      `The trip "${trip.title}" has been cancelled`,
      req.user.userId
    );
    
    res.json({ message: 'Trip cancelled successfully' });
  } catch (error) {
    console.error('Cancel trip error:', error);
    res.status(500).json({ message: 'Failed to cancel trip' });
  }
});

module.exports = router; 