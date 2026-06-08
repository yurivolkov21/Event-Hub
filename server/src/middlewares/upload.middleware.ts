import multer from 'multer';

import { AppError } from './error.middleware';

const allowedImageMimeTypes = new Set([
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/gif',
]);

export const uploadEventImage = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024,
    files: 1,
  },
  fileFilter(_req, file, callback) {
    if (!allowedImageMimeTypes.has(file.mimetype)) {
      return callback(new AppError('Only image files are allowed', 400));
    }

    return callback(null, true);
  },
}).single('image');
