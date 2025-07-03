const express = require('express');
const router = express.Router();
const tripController = require('../controllers/tripController');
const auth = require('../middleware/auth');

router.post('/create', auth, tripController.createTrip);
router.get('/my', auth, tripController.listMyTrips);
router.put('/cancel', auth, tripController.cancelTrip);
router.post('/match', auth, tripController.findMatches);

module.exports = router; 