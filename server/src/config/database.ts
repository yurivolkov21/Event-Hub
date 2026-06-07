import mongoose from 'mongoose';

import { env } from './env';

export const connectDatabase = async (): Promise<void> => {
  mongoose.set('strictQuery', true);

  await mongoose.connect(env.MONGODB_URI);
};

export const getDatabaseStatus = () => {
  const states: Record<number, string> = {
    0: 'disconnected',
    1: 'connected',
    2: 'connecting',
    3: 'disconnecting',
  };

  return {
    readyState: mongoose.connection.readyState,
    status: states[mongoose.connection.readyState] ?? 'unknown',
    name: mongoose.connection.name || null,
    host: mongoose.connection.host || null,
  };
};

export const disconnectDatabase = async (): Promise<void> => {
  await mongoose.disconnect();
};
