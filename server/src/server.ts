import dotenv from 'dotenv';
import path from 'path';
import app from './app';

// Load .env from root of server
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

const PORT = Number(process.env.PORT || 3000);
const HOST = '0.0.0.0';

app.listen(PORT, HOST, () => {
  console.log(`🚀 Server ready at http://localhost:${PORT}`);
});
