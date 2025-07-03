const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const http = require('http');
const { Server } = require('socket.io');
const userRoutes = require('./routes/userRoutes');
const tripRoutes = require('./routes/tripRoutes');
const chatRoutes = require('./routes/chatRoutes');
const notificationRoutes = require('./routes/notificationRoutes');

dotenv.config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

app.use(cors());
app.use(express.json());

// Test route
app.get('/', (req, res) => {
  res.send('TravelBuddy backend is running!');
});

// TODO: Add routes for users, trips, chat
app.use('/api/users', userRoutes);
app.use('/api/trips', tripRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/notifications', notificationRoutes);

// Socket.IO logic for real-time group chat
const Chat = require('./models/chat');
io.on('connection', (socket) => {
  socket.on('joinGroup', ({ groupId, userId }) => {
    socket.join(`group_${groupId}`);
  });

  socket.on('sendMessage', async ({ groupId, senderId, content }) => {
    await Chat.saveMessage(groupId, senderId, content);
    io.to(`group_${groupId}`).emit('newMessage', { groupId, senderId, content, timestamp: new Date() });
  });
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
}); 