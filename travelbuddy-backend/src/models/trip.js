const mysql = require('mysql2/promise');

class Trip {
  constructor(pool) {
    this.pool = pool;
  }

  async create(tripData) {
    const { title, description, destination, startDate, endDate, maxMembers, creatorId, budget, interests } = tripData;
    const [result] = await this.pool.execute(
      'INSERT INTO trips (title, description, destination, start_date, end_date, max_members, creator_id, budget, interests) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [title, description, destination, startDate, endDate, maxMembers, creatorId, budget, interests]
    );
    return result.insertId;
  }

  async findById(id) {
    const [rows] = await this.pool.execute(`
      SELECT t.*, u.name as creator_name, u.college as creator_college,
             COUNT(tm.user_id) as current_members
      FROM trips t
      LEFT JOIN users u ON t.creator_id = u.id
      LEFT JOIN trip_members tm ON t.id = tm.trip_id
      WHERE t.id = ?
      GROUP BY t.id
    `, [id]);
    return rows[0];
  }

  async findAll() {
    const [rows] = await this.pool.execute(`
      SELECT t.*, u.name as creator_name, u.college as creator_college,
             COUNT(tm.user_id) as current_members
      FROM trips t
      LEFT JOIN users u ON t.creator_id = u.id
      LEFT JOIN trip_members tm ON t.id = tm.trip_id
      WHERE t.status = 'active'
      GROUP BY t.id
      ORDER BY t.created_at DESC
    `);
    return rows;
  }

  async findByCreator(creatorId) {
    const [rows] = await this.pool.execute(`
      SELECT t.*, u.name as creator_name, u.college as creator_college,
             COUNT(tm.user_id) as current_members
      FROM trips t
      LEFT JOIN users u ON t.creator_id = u.id
      LEFT JOIN trip_members tm ON t.id = tm.trip_id
      WHERE t.creator_id = ?
      GROUP BY t.id
      ORDER BY t.created_at DESC
    `, [creatorId]);
    return rows;
  }

  async findUserTrips(userId) {
    const [rows] = await this.pool.execute(`
      SELECT t.*, u.name as creator_name, u.college as creator_college,
             COUNT(tm2.user_id) as current_members
      FROM trips t
      LEFT JOIN users u ON t.creator_id = u.id
      LEFT JOIN trip_members tm ON t.id = tm.trip_id AND tm.user_id = ?
      LEFT JOIN trip_members tm2 ON t.id = tm2.trip_id
      WHERE tm.user_id IS NOT NULL OR t.creator_id = ?
      GROUP BY t.id
      ORDER BY t.created_at DESC
    `, [userId, userId]);
    return rows;
  }

  async findMatches(userId, userCollege, userInterests) {
    const [rows] = await this.pool.execute(`
      SELECT t.*, u.name as creator_name, u.college as creator_college,
             COUNT(tm.user_id) as current_members
      FROM trips t
      LEFT JOIN users u ON t.creator_id = u.id
      LEFT JOIN trip_members tm ON t.id = tm.trip_id
      WHERE t.status = 'active' 
        AND t.creator_id != ?
        AND t.max_members > COUNT(tm.user_id)
        AND (u.college = ? OR t.interests LIKE ?)
      GROUP BY t.id
      ORDER BY 
        CASE WHEN u.college = ? THEN 1 ELSE 0 END DESC,
        t.created_at DESC
    `, [userId, userCollege, `%${userInterests}%`, userCollege]);
    return rows;
  }

  async addMember(tripId, userId) {
    await this.pool.execute(
      'INSERT INTO trip_members (trip_id, user_id) VALUES (?, ?)',
      [tripId, userId]
    );
  }

  async removeMember(tripId, userId) {
    await this.pool.execute(
      'DELETE FROM trip_members WHERE trip_id = ? AND user_id = ?',
      [tripId, userId]
    );
  }

  async getMembers(tripId) {
    const [rows] = await this.pool.execute(`
      SELECT u.id, u.name, u.email, u.college
      FROM trip_members tm
      JOIN users u ON tm.user_id = u.id
      WHERE tm.trip_id = ?
    `, [tripId]);
    return rows;
  }

  async update(id, tripData) {
    const { title, description, destination, startDate, endDate, maxMembers, budget, interests } = tripData;
    await this.pool.execute(
      'UPDATE trips SET title = ?, description = ?, destination = ?, start_date = ?, end_date = ?, max_members = ?, budget = ?, interests = ? WHERE id = ?',
      [title, description, destination, startDate, endDate, maxMembers, budget, interests, id]
    );
    return this.findById(id);
  }

  async delete(id) {
    await this.pool.execute('DELETE FROM trips WHERE id = ?', [id]);
  }
}

module.exports = Trip; 