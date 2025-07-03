const express = require('express');
const { authenticateToken } = require('../middleware/auth');
const User = require('../models/user');
const { pool } = require('../../config/db');

// Initialize model with pool
const userModel = new User(pool);

const router = express.Router();

// Get user profile
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const user = await userModel.findById(req.user.userId);
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    res.json({ user });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ message: 'Failed to get profile' });
  }
});

// Update user profile
router.put('/profile', authenticateToken, async (req, res) => {
  try {
    const { name, college } = req.body;
    
    const updatedUser = await userModel.update(req.user.userId, { name, college });
    
    res.json({
      message: 'Profile updated successfully',
      user: updatedUser
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ message: 'Failed to update profile' });
  }
});

// Get users by college
router.get('/college/:college', authenticateToken, async (req, res) => {
  try {
    const { college } = req.params;
    const users = await userModel.findByCollege(college);
    
    res.json({ users });
  } catch (error) {
    console.error('Get users by college error:', error);
    res.status(500).json({ message: 'Failed to get users' });
  }
});

module.exports = router; 