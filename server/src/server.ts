import dotenv from 'dotenv';
import path from 'path';
import http from 'http';
import app from './app';
import { validateRuntimeEnv } from './config/runtime';
import { socketService } from './services/communication/SocketService';

// Load .env from root of server
dotenv.config({ path: path.resolve(__dirname, '../.env') });

validateRuntimeEnv();

const PORT = Number(process.env.PORT || 3000);
const HOST = '0.0.0.0';

const server = http.createServer(app);

// Initialize Socket.io
socketService.initialize(server);

server.listen(PORT, HOST, () => {
  console.log(`🚀 Server ready at http://localhost:${PORT}`);
});
