const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const DeviceToken = require('../models/deviceToken');

router.post('/register', auth, async (req, res) => {
  try {
    await DeviceToken.save(req.user.id, req.body.token);
    res.json({ message: 'Token saved' });
  } catch (err) {
    res.status(500).json({ message: 'Failed to save token', error: err.message });
  }
});

module.exports = router; 