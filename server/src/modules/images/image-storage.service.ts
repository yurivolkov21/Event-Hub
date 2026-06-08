import {
  v2 as cloudinary,
  type UploadApiResponse,
} from 'cloudinary';

import { env } from '../../config/env';
import { AppError } from '../../middlewares/error.middleware';

interface UploadedImage {
  imageUrl: string;
  imagePublicId: string;
}

const placeholderValues = new Set([
  'your-cloud-name',
  'your-api-key',
  'your-api-secret',
]);

const isUsableValue = (value: string | undefined): value is string => {
  return Boolean(value && !placeholderValues.has(value));
};

export const isCloudinaryConfigured = (): boolean => {
  return (
    isUsableValue(env.CLOUDINARY_CLOUD_NAME) &&
    isUsableValue(env.CLOUDINARY_API_KEY) &&
    isUsableValue(env.CLOUDINARY_API_SECRET)
  );
};

let isConfigured = false;

const configureCloudinary = () => {
  if (!isCloudinaryConfigured()) {
    throw new AppError('Cloudinary image storage is not configured', 500);
  }

  if (isConfigured) {
    return;
  }

  cloudinary.config({
    cloud_name: env.CLOUDINARY_CLOUD_NAME,
    api_key: env.CLOUDINARY_API_KEY,
    api_secret: env.CLOUDINARY_API_SECRET,
    secure: true,
  });

  isConfigured = true;
};

const uploadBuffer = (
  file: Express.Multer.File,
): Promise<UploadApiResponse> => {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      {
        folder: env.CLOUDINARY_FOLDER,
        resource_type: 'image',
        unique_filename: true,
        overwrite: false,
      },
      (error, result) => {
        if (error) {
          reject(new AppError('Image upload failed', 500));
          return;
        }

        if (!result) {
          reject(new AppError('Image upload did not return a result', 500));
          return;
        }

        resolve(result);
      },
    );

    stream.end(file.buffer);
  });
};

export const uploadImageToCloudinary = async (
  file: Express.Multer.File,
): Promise<UploadedImage> => {
  configureCloudinary();

  const result = await uploadBuffer(file);

  return {
    imageUrl: result.secure_url,
    imagePublicId: result.public_id,
  };
};

export const deleteImageFromCloudinary = async (
  publicId: string | null | undefined,
): Promise<void> => {
  if (!publicId) {
    return;
  }

  configureCloudinary();

  await cloudinary.uploader.destroy(publicId, {
    invalidate: true,
    resource_type: 'image',
  });
};
