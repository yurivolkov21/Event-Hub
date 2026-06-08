import {
  cert,
  getApp,
  getApps,
  initializeApp,
  type App,
} from 'firebase-admin/app';
import { getStorage } from 'firebase-admin/storage';

import { env } from './env';
import { AppError } from '../middlewares/error.middleware';

const placeholderValues = new Set([
  'your-project-id',
  'firebase-adminsdk@example.iam.gserviceaccount.com',
  '-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n',
  'your-project-id.appspot.com',
]);

const normalizePrivateKey = (privateKey: string): string => {
  return privateKey.replace(/\\n/g, '\n');
};

const isUsableValue = (value: string | undefined): value is string => {
  return Boolean(value && !placeholderValues.has(normalizePrivateKey(value)));
};

export const isFirebaseStorageConfigured = (): boolean => {
  return (
    isUsableValue(env.FIREBASE_PROJECT_ID) &&
    isUsableValue(env.FIREBASE_CLIENT_EMAIL) &&
    isUsableValue(env.FIREBASE_PRIVATE_KEY) &&
    isUsableValue(env.FIREBASE_STORAGE_BUCKET)
  );
};

const getFirebaseApp = (): App => {
  const projectId = env.FIREBASE_PROJECT_ID;
  const clientEmail = env.FIREBASE_CLIENT_EMAIL;
  const privateKey = env.FIREBASE_PRIVATE_KEY;
  const storageBucket = env.FIREBASE_STORAGE_BUCKET;

  if (
    !isFirebaseStorageConfigured() ||
    !projectId ||
    !clientEmail ||
    !privateKey ||
    !storageBucket
  ) {
    throw new AppError('Firebase Storage is not configured', 500);
  }

  if (getApps().length > 0) {
    return getApp();
  }

  return initializeApp({
    credential: cert({
      projectId,
      clientEmail,
      privateKey: normalizePrivateKey(privateKey),
    }),
    storageBucket,
  });
};

export const getFirebaseStorageBucket = () => {
  const app = getFirebaseApp();

  return getStorage(app).bucket();
};
