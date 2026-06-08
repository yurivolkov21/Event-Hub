import { randomUUID } from 'node:crypto';
import path from 'node:path';

import { getFirebaseStorageBucket } from '../../config/firebase';

const getSafeExtension = (originalName: string, mimeType: string): string => {
  const extension = path.extname(originalName).toLowerCase();

  if (extension) {
    return extension;
  }

  const mimeExtensions: Record<string, string> = {
    'image/jpeg': '.jpg',
    'image/png': '.png',
    'image/webp': '.webp',
    'image/gif': '.gif',
  };

  return mimeExtensions[mimeType] ?? '.jpg';
};

export const uploadImageToFirebaseStorage = async (
  file: Express.Multer.File,
  folder = 'event-images',
): Promise<string> => {
  const bucket = getFirebaseStorageBucket();
  const token = randomUUID();
  const extension = getSafeExtension(file.originalname, file.mimetype);
  const fileName = `${folder}/${Date.now()}-${randomUUID()}${extension}`;
  const storageFile = bucket.file(fileName);

  await storageFile.save(file.buffer, {
    contentType: file.mimetype,
    resumable: false,
    metadata: {
      metadata: {
        firebaseStorageDownloadTokens: token,
      },
    },
  });

  return `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(
    fileName,
  )}?alt=media&token=${token}`;
};
