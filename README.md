# TravelBuddy - Complete Travel Companion App

A comprehensive Flutter app with Node.js backend for finding travel buddies, managing trips, and real-time group chat functionality.

## 🚀 Features

### Frontend (Flutter)
- **Authentication**: Login, registration, and profile management
- **Trip Management**: Create, join, and manage trips
- **Smart Matching**: AI-powered trip matching based on preferences
- **Real-time Chat**: (In Progress) – Group chat for trip members is being developed
- **Push Notifications**: Real-time notifications for trip updates
- **Modern UI**: Beautiful, responsive design with animations
- **Searchable College Dropdown**: Enhanced user experience

### Backend (Node.js)
- **RESTful API**: Complete CRUD operations for all entities
- **JWT Authentication**: Secure user authentication
- **Socket.IO**: Real-time messaging and notifications
- **MySQL Database**: Reliable data storage
- **Smart Matching Algorithm**: Intelligent trip recommendations
- **Push Notifications**: Firebase integration for mobile notifications

## 📱 Screenshots

The app includes the following screens:
- Onboarding screens
- Login/Registration with searchable college dropdown
- Home screen with quick actions
- Trip creation and management
- Trip listing and details
- Group chat for trip members (In Progress)
- Notifications center
- User profile management

## 🛠️ Tech Stack

### Frontend
- **Flutter**: Cross-platform mobile development
- **Provider**: State management
- **Socket.IO**: Real-time communication
- **Shared Preferences**: Local storage
- **HTTP**: API communication

### Backend
- **Node.js**: Server runtime
- **Express.js**: Web framework
- **MySQL**: Database
- **Socket.IO**: Real-time features
- **JWT**: Authentication
- **bcrypt**: Password hashing
- **CORS**: Cross-origin resource sharing

## 📋 Prerequisites

- Flutter SDK (latest stable version)
- Node.js (v16 or higher)
- MySQL (v8.0 or higher)
- Git

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone <repository-url>
cd TravelBuddy
```

### 2. Backend Setup

#### Navigate to backend directory
```bash
cd travelbuddy-backend
```

#### Install dependencies
```bash
npm install
```

#### Database Setup
1. Create a MySQL database named `travelbuddy`
2. Update database configuration in `config/db.js`:
```javascript
const dbConfig = {
  host: 'localhost',
  user: 'your_username',
  password: 'your_password',
  database: 'travelbuddy',
  // ... other config
};
```

#### Create Database Tables
Run the following SQL commands in your MySQL database:

```sql
-- Users table
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  college VARCHAR(255),
  interests TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Trips table
CREATE TABLE trips (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  destination VARCHAR(255) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  max_members INT DEFAULT 4,
  creator_id INT NOT NULL,
  budget DECIMAL(10,2),
  interests TEXT,
  status ENUM('active', 'completed', 'cancelled') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Trip members table
CREATE TABLE trip_members (
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

-- Group members table
CREATE TABLE group_members (
  id INT PRIMARY KEY AUTO_INCREMENT,
  group_id INT NOT NULL,
  user_id INT NOT NULL,
  joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (group_id) REFERENCES group_chats(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_group_user (group_id, user_id)
);

-- Group messages table
CREATE TABLE group_messages (
  id INT PRIMARY KEY AUTO_INCREMENT,
  group_id INT NOT NULL,
  sender_id INT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (group_id) REFERENCES group_chats(id) ON DELETE CASCADE,
  FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Notifications table
CREATE TABLE notifications (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  type ENUM('trip', 'match', 'message', 'system') DEFAULT 'system',
  related_id INT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Device tokens table (for push notifications)
CREATE TABLE device_tokens (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  token VARCHAR(500) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_token (user_id, token)
);
```

#### Start the backend server
```bash
npm start
```

The backend will run on `http://localhost:3000`

### 3. Frontend Setup

#### Navigate to Flutter app directory
```bash
cd travel_buddy
```

#### Install dependencies
```bash
flutter pub get
```

#### Update API Configuration
Update the API base URL in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

#### Run the Flutter app
```bash
flutter run
```

## 📱 App Structure

### Backend Structure
```
travelbuddy-backend/
├── config/
│   └── db.js
├── src/
│   ├── controllers/
│   │   ├── chatController.js
│   │   ├── notificationController.js
│   │   └── tripController.js
│   ├── middleware/
│   │   └── auth.js
│   ├── models/
│   │   ├── chat.js
│   │   ├── notification.js
│   │   ├── trip.js
│   │   └── user.js
│   ├── routes/
│   │   ├── authRoutes.js
│   │   ├── chatRoutes.js
│   │   ├── notificationRoutes.js
│   │   ├── tripRoutes.js
│   │   └── userRoutes.js
│   └── utils/
├── package.json
├── start.js
└── README.md
```

### Frontend Structure
```
travel_buddy/
├── lib/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   ├── models/
│   │   ├── trip.dart
│   │   └── user.dart
│   ├── providers/
│   │   └── theme_provider.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── chat/
│   │   │   ├── chat_list_screen.dart
│   │   │   ├── chat_screen.dart
│   │   │   └── group_chat_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   ├── new_trip_screen.dart
│   │   │   └── my_trips_screen.dart
│   │   ├── trips/
│   │   │   ├── trip_list_screen.dart
│   │   │   └── trip_detail_screen.dart
│   │   ├── profile/
│   │   │   └── profile_screen.dart
│   │   └── notifications_screen.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── chat_service.dart
│   │   ├── notification_service.dart
│   │   └── trip_service.dart
│   ├── widgets/
│   │   ├── custom_button.dart
│   │   ├── custom_input_field.dart
│   │   └── searchable_college_dropdown.dart
│   └── main.dart
├── pubspec.yaml
└── README.md
```

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the backend directory:
```env
DB_HOST=localhost
DB_USER=your_username
DB_PASSWORD=your_password
DB_NAME=travelbuddy
JWT_SECRET=your-secret-key-change-this-in-production
PORT=3000
```

### API Endpoints

#### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout

#### User Management
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update user profile

#### Trip Management
- `POST /api/trips` - Create new trip
- `GET /api/trips` - Get all trips
- `GET /api/trips/my` - Get user's trips
- `GET /api/trips/matches` - Get trip matches
- `GET /api/trips/:id` - Get trip details
- `POST /api/trips/:id/join` - Join trip
- `POST /api/trips/:id/leave` - Leave trip
- `DELETE /api/trips/:id` - Cancel trip

#### Chat
- `GET /api/chat/groups` - Get user's group chats
- `GET /api/chat/groups/:id/messages` - Get group messages
- `POST /api/chat/groups/:id/messages` - Send message
- `GET /api/chat/groups/:id/members` - Get group members

#### Notifications
- `GET /api/notifications` - Get user notifications
- `PUT /api/notifications/:id/read` - Mark as read
- `GET /api/notifications/unread-count` - Get unread count
- `POST /api/notifications/register` - Register device token

## 🚀 Running the App

1. **Start the backend server**:
   ```bash
   cd travelbuddy-backend
   npm start
   ```

2. **Start the Flutter app**:
   ```bash
   cd travel_buddy
   flutter run
   ```

3. **Access the app**:
   - Backend API: `http://localhost:3000`
   - Flutter app: Run on your device/emulator

## 🧪 Testing

### Backend Testing
```bash
cd travelbuddy-backend
npm test
```

### Frontend Testing
```bash
cd travel_buddy
flutter test
```

## 📦 Deployment

### Backend Deployment
1. Set up a production database
2. Update environment variables
3. Deploy to your preferred hosting service (Heroku, AWS, etc.)

### Frontend Deployment
1. Build the Flutter app:
   ```bash
   flutter build apk  # For Android
   flutter build ios  # For iOS
   ```
2. Deploy to app stores or distribute the APK

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

If you encounter any issues or have questions:
1. Check the documentation
2. Search existing issues
3. Create a new issue with detailed information

## 🎯 Roadmap

- [ ] Push notification integration
- [ ] Advanced trip matching algorithm
- [ ] Trip ratings and reviews
- [ ] Payment integration
- [ ] Offline mode support
- [ ] Multi-language support
- [ ] Dark mode improvements
- [ ] Performance optimizations
- [ ] Group chat and real-time conversation features

---

**Happy Traveling! 🚀✈️** 