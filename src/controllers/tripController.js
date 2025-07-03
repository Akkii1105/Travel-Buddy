const Trip = require('../models/trip');
const User = require('../models/user');

exports.createTrip = async (req, res) => {
  try {
    const user_id = req.user.id;
    const { source, destination, start_time, end_time } = req.body;
    if (!source || !destination || !start_time || !end_time) {
      return res.status(400).json({ message: 'All fields are required.' });
    }
    const tripId = await Trip.create({ user_id, source, destination, start_time, end_time });
    res.status(201).json({ tripId });
  } catch (err) {
    res.status(500).json({ message: 'Trip creation failed', error: err.message });
  }
};

exports.listMyTrips = async (req, res) => {
  try {
    const user_id = req.user.id;
    const trips = await Trip.listByUser(user_id);
    res.json(trips);
  } catch (err) {
    res.status(500).json({ message: 'Failed to fetch trips', error: err.message });
  }
};

exports.cancelTrip = async (req, res) => {
  try {
    const user_id = req.user.id;
    const { tripId } = req.body;
    await Trip.cancel(tripId, user_id);
    res.json({ message: 'Trip cancelled' });
  } catch (err) {
    res.status(500).json({ message: 'Failed to cancel trip', error: err.message });
  }
};

exports.findMatches = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    const { source, destination, start_time, end_time } = req.body;
    const matches = await Trip.findMatching({
      college: user.college,
      source,
      destination,
      start_time,
      end_time,
    });
    res.json(matches);
  } catch (err) {
    res.status(500).json({ message: 'Failed to find matches', error: err.message });
  }
}; 