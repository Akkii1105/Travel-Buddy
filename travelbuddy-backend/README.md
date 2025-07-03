# TravelBuddy Backend

A Node.js backend for the TravelBuddy Flutter app with user authentication, trip management, and real-time chat.

## Features

- User authentication (register, login, logout)
- User profile management
- Trip creation, listing, and management
- Smart trip matching
- Real-time chat using Socket.IO
- Push notifications

## Prerequisites

- Node.js (v14 or higher)
- MySQL (v8.0 or higher)
- npm or yarn

## Setup Instructions

### 1. Install Dependencies

```bash
npm install
```

### 2. Database Setup

1. Create a MySQL database named `travelbuddy`
2. Run the following SQL commands to create the required tables:

```sql
-- Users table
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  college VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Trips table
CREATE TABLE trips (
  id INT PRIMARY KEY AUTO_INCREMENT,
  creator_id INT NOT NULL,
  source VARCHAR(255) NOT NULL,
  destination VARCHAR(255) NOT NULL,
  departure_time DATETIME NOT NULL,
  available_seats INT NOT NULL,
  description TEXT,
  status ENUM('active', 'cancelled', 'completed') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Trip participants table
CREATE TABLE trip_participants (
  id INT PRIMARY KEY AUTO_INCREMENT,
  trip_id INT NOT NULL,
  user_id INT NOT NULL,
  joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_trip_user (trip_id, user_id)
);

-- Group chats table
CREATE TABLE group_chats (
  id INT PRIMARY KEY AUTO_INCREMENT,
  trip_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
);

-- Group chat members table
CREATE TABLE group_chat_members (
  id INT PRIMARY KEY AUTO_INCREMENT,
  group_id INT NOT NULL,
  user_id INT NOT NULL,
  joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (group_id) REFERENCES group_chats(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_group_user (group_id, user_id)
);

-- Messages table
CREATE TABLE messages (
  id INT PRIMARY KEY AUTO_INCREMENT,
  group_id INT NOT NULL,
  sender_id INT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (group_id) REFERENCES group_chats(id) ON DELETE CASCADE,
  FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Device tokens table (for push notifications)
CREATE TABLE device_tokens (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  device_token VARCHAR(500) NOT NULL,
  platform ENUM('android', 'ios', 'web') DEFAULT 'android',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_token (user_id, device_token)
);
```

### 3. Configuration

Update the database configuration in `start.js`:

```javascript
const dbConfig = {
  host: 'localhost',
  user: 'root',
  password: 'your_mysql_password', // Change this
  database: 'travelbuddy',
  // ... other config
};
```

### 4. Start the Server

```bash
node start.js
```

The server will start on port 3000 by default.

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user

### User Management
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update user profile

## Socket.IO Events

### Client to Server
- `join_group` - Join a group chat
- `leave_group` - Leave a group chat
- `send_message` - Send a message to group

### Server to Client
- `message` - Receive a new message
- `notification` - Receive a notification
- `match_found` - Trip match found 