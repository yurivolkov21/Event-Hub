import { z } from 'zod';

import { fcmTokenPlatforms } from './fcm-token.model';

const objectIdSchema = z
  .string()
  .regex(/^[a-f\d]{24}$/i, 'Invalid ObjectId');

export const notificationIdParamSchema = z.object({
  id: objectIdSchema,
});

export const listNotificationsQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(50).default(20),
  unreadOnly: z
    .enum(['true', 'false'])
    .optional()
    .transform((value) => value === 'true'),
});

export const registerFcmTokenSchema = z.object({
  token: z
    .string()
    .trim()
    .min(20, 'FCM token is too short')
    .max(4096, 'FCM token is too long'),
  platform: z.enum(fcmTokenPlatforms).default('android'),
  appVersion: z.string().trim().max(80).optional().nullable(),
});

export type ListNotificationsQuery = z.infer<
  typeof listNotificationsQuerySchema
>;
export type RegisterFcmTokenInput = z.infer<typeof registerFcmTokenSchema>;
