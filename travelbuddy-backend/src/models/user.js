const mysql = require('mysql2/promise');

class User {
  constructor(pool) {
    this.pool = pool;
  }

  async create(userData) {
    const { name, email, password, college } = userData;
    const [result] = await this.pool.execute(
      'INSERT INTO users (name, email, password, college) VALUES (?, ?, ?, ?)',
      [name, email, password, college]
    );
    return result.insertId;
  }

  async findByEmail(email) {
    const [rows] = await this.pool.execute('SELECT * FROM users WHERE email = ?', [email]);
    return rows[0];
  }

  async findById(id) {
    const [rows] = await this.pool.execute('SELECT id, name, email, college FROM users WHERE id = ?', [id]);
    return rows[0];
  }

  async update(id, userData) {
    const { name, college } = userData;
    await this.pool.execute(
      'UPDATE users SET name = ?, college = ? WHERE id = ?',
      [name, college, id]
    );
    return this.findById(id);
  }

  async findByCollege(college) {
    const [rows] = await this.pool.execute('SELECT id, name, email, college FROM users WHERE college = ?', [college]);
    return rows;
  }
}

module.exports = User; 