const pool = require('../config/db');
const { authenticateToken } = require('../middleware/auth');
const cron = require('node-cron');
const { sendTripNotification } = require('./notificationController');

// Create a new trip
const createTrip = async (req, res) => {
  try {
    const { source, destination, departureTime, availableSeats, description } = req.body;
    const creatorId = req.user.userId;

    const [result] = await pool.execute(
      'INSERT INTO trips (creator_id, source, destination, departure_time, available_seats, description) VALUES (?, ?, ?, ?, ?, ?)',
      [creatorId, source, destination, departureTime, availableSeats, description]
    );

    // Add creator as first participant
    await pool.execute(
      'INSERT INTO trip_participants (trip_id, user_id) VALUES (?, ?)',
      [result.insertId, creatorId]
    );

    // Schedule trip reminder notification 1 hour before departure
    const tripId = result.insertId;
    const reminderTime = new Date(new Date(departureTime) - 60 * 60 * 1000); // 1 hour before
    const cronTime = `${reminderTime.getMinutes()} ${reminderTime.getHours()} ${reminderTime.getDate()} ${reminderTime.getMonth() + 1} *`;
    cron.schedule(cronTime, () => {
      sendTripNotification(tripId, 'Trip Reminder', `Your trip to ${destination} starts in 1 hour!`);
    });

    res.status(201).json({
      message: 'Trip created successfully',
      trip: {
        id: result.insertId,
        creatorId,
        source,
        destination,
        departureTime,
        availableSeats,
        description,
        status: 'active'
      }
    });
  } catch (error) {
    console.error('Create trip error:', error);
    res.status(500).json({ message: 'Failed to create trip' });
  }
};

// Get all trips with filters
const getTrips = async (req, res) => {
  try {
    const { source, destination, departureDate } = req.query;
    let query = `
      SELECT t.*, u.name as creator_name, u.college as creator_college,
             COUNT(tp.user_id) as current_participants
      FROM trips t
      LEFT JOIN users u ON t.creator_id = u.id
      LEFT JOIN trip_participants tp ON t.id = tp.trip_id
      WHERE t.status = 'active'
    `;
    const params = [];

    if (source) {
      query += ' AND t.source LIKE ?';
      params.push(`%${source}%`);
    }
    if (destination) {
      query += ' AND t.destination LIKE ?';
      params.push(`%${destination}%`);
    }
    if (departureDate) {
      query += ' AND DATE(t.departure_time) = ?';
      params.push(departureDate);
    }

    query += ' GROUP BY t.id ORDER BY t.departure_time ASC';

    const [trips] = await pool.execute(query, params);
    res.json({ trips });
  } catch (error) {
    console.error('Get trips error:', error);
    res.status(500).json({ message: 'Failed to get trips' });
  }
};

// Get user's own trips
const getMyTrips = async (req, res) => {
  try {
    const userId = req.user.userId;
    
    const [trips] = await pool.execute(`
      SELECT t.*, u.name as creator_name, u.college as creator_college,
             COUNT(tp.user_id) as current_participants
      FROM trips t
      LEFT JOIN users u ON t.creator_id = u.id
      LEFT JOIN trip_participants tp ON t.id = tp.trip_id
      WHERE t.creator_id = ? OR t.id IN (
        SELECT trip_id FROM trip_participants WHERE user_id = ?
      )
      GROUP BY t.id
      ORDER BY t.departure_time ASC
    `, [userId, userId]);

    res.json({ trips });
  } catch (error) {
    console.error('Get my trips error:', error);
    res.status(500).json({ message: 'Failed to get trips' });
  }
};

// Get trip details by ID
const getTripById = async (req, res) => {
  try {
    const { tripId } = req.params;
    
    const [trips] = await pool.execute(`
      SELECT t.*, u.name as creator_name, u.college as creator_college
      FROM trips t
      LEFT JOIN users u ON t.creator_id = u.id
      WHERE t.id = ?
    `, [tripId]);

    if (trips.length === 0) {
      return res.status(404).json({ message: 'Trip not found' });
    }

    const [participants] = await pool.execute(`
      SELECT u.id, u.name, u.college, tp.joined_at
      FROM trip_participants tp
      LEFT JOIN users u ON tp.user_id = u.id
      WHERE tp.trip_id = ?
      ORDER BY tp.joined_at ASC
    `, [tripId]);

    res.json({
      trip: { ...trips[0], participants }
    });
  } catch (error) {
    console.error('Get trip error:', error);
    res.status(500).json({ message: 'Failed to get trip' });
  }
};

// Join a trip
const joinTrip = async (req, res) => {
  try {
    const { tripId } = req.params;
    const userId = req.user.userId;

    // Check if trip exists and has available seats
    const [trips] = await pool.execute(
      'SELECT * FROM trips WHERE id = ? AND status = "active"',
      [tripId]
    );

    if (trips.length === 0) {
      return res.status(404).json({ message: 'Trip not found or inactive' });
    }

    const trip = trips[0];
    const [participants] = await pool.execute(
      'SELECT COUNT(*) as count FROM trip_participants WHERE trip_id = ?',
      [tripId]
    );

    if (participants[0].count >= trip.available_seats) {
      return res.status(400).json({ message: 'Trip is full' });
    }

    // Check if user is already a participant
    const [existing] = await pool.execute(
      'SELECT * FROM trip_participants WHERE trip_id = ? AND user_id = ?',
      [tripId, userId]
    );

    if (existing.length > 0) {
      return res.status(400).json({ message: 'Already joined this trip' });
    }

    // Add user to trip
    await pool.execute(
      'INSERT INTO trip_participants (trip_id, user_id) VALUES (?, ?)',
      [tripId, userId]
    );

    res.json({ message: 'Successfully joined trip' });
  } catch (error) {
    console.error('Join trip error:', error);
    res.status(500).json({ message: 'Failed to join trip' });
  }
};

// Leave a trip
const leaveTrip = async (req, res) => {
  try {
    const { tripId } = req.params;
    const userId = req.user.userId;

    // Check if user is a participant
    const [participants] = await pool.execute(
      'SELECT * FROM trip_participants WHERE trip_id = ? AND user_id = ?',
      [tripId, userId]
    );

    if (participants.length === 0) {
      return res.status(400).json({ message: 'Not a participant of this trip' });
    }

    // Remove user from trip
    await pool.execute(
      'DELETE FROM trip_participants WHERE trip_id = ? AND user_id = ?',
      [tripId, userId]
    );

    res.json({ message: 'Successfully left trip' });
  } catch (error) {
    console.error('Leave trip error:', error);
    res.status(500).json({ message: 'Failed to leave trip' });
  }
};

// Cancel a trip (only creator can cancel)
const cancelTrip = async (req, res) => {
  try {
    const { tripId } = req.params;
    const userId = req.user.userId;

    // Check if user is the creator
    const [trips] = await pool.execute(
      'SELECT * FROM trips WHERE id = ? AND creator_id = ?',
      [tripId, userId]
    );

    if (trips.length === 0) {
      return res.status(403).json({ message: 'Only trip creator can cancel trip' });
    }

    // Update trip status
    await pool.execute(
      'UPDATE trips SET status = "cancelled" WHERE id = ?',
      [tripId]
    );

    res.json({ message: 'Trip cancelled successfully' });
  } catch (error) {
    console.error('Cancel trip error:', error);
    res.status(500).json({ message: 'Failed to cancel trip' });
  }
};

// Smart trip matching algorithm
const getTripMatches = async (req, res) => {
  try {
    const userId = req.user.userId;

    // Get user's college
    const [users] = await pool.execute(
      'SELECT college FROM users WHERE id = ?',
      [userId]
    );

    if (users.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    const userCollege = users[0].college;

    // Find matching trips based on:
    // 1. Same college
    // 2. Similar departure time (within 2 hours)
    // 3. Same source or destination
    const [matches] = await pool.execute(`
      SELECT DISTINCT t.*, u.name as creator_name, u.college as creator_college,
             COUNT(tp.user_id) as current_participants,
             CASE 
               WHEN t.source = (SELECT source FROM trips WHERE creator_id = ? ORDER BY created_at DESC LIMIT 1) THEN 'same_source'
               WHEN t.destination = (SELECT destination FROM trips WHERE creator_id = ? ORDER BY created_at DESC LIMIT 1) THEN 'same_destination'
               ELSE 'college_match'
             END as match_type
      FROM trips t
      LEFT JOIN users u ON t.creator_id = u.id
      LEFT JOIN trip_participants tp ON t.id = tp.trip_id
      WHERE t.status = 'active' 
        AND t.creator_id != ?
        AND u.college = ?
        AND t.departure_time > NOW()
        AND t.id NOT IN (
          SELECT trip_id FROM trip_participants WHERE user_id = ?
        )
      GROUP BY t.id
      ORDER BY 
        CASE 
          WHEN t.source = (SELECT source FROM trips WHERE creator_id = ? ORDER BY created_at DESC LIMIT 1) THEN 1
          WHEN t.destination = (SELECT destination FROM trips WHERE creator_id = ? ORDER BY created_at DESC LIMIT 1) THEN 2
          ELSE 3
        END,
        t.departure_time ASC
      LIMIT 10
    `, [userId, userId, userId, userCollege, userId, userId, userId]);

    res.json({ matches });
  } catch (error) {
    console.error('Get matches error:', error);
    res.status(500).json({ message: 'Failed to get matches' });
  }
};

module.exports = {
  createTrip,
  getTrips,
  getMyTrips,
  getTripById,
  joinTrip,
  leaveTrip,
  cancelTrip,
  getTripMatches
}; 