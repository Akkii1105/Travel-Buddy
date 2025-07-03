const db = require('../../config/db');

const DeviceToken = {
  save: async (user_id, token) => {
    await db.execute(
      'INSERT INTO device_tokens (user_id, token) VALUES (?, ?) ON DUPLICATE KEY UPDATE token = VALUES(token)',
      [user_id, token]
    );
  }
};

module.exports = DeviceToken; 