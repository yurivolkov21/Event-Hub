import { z } from 'zod';

const objectIdSchema = z
  .string()
  .regex(/^[a-f\d]{24}$/i, 'Invalid ObjectId');

export const bookmarkEventParamSchema = z.object({
  eventId: objectIdSchema,
});

export const listBookmarksQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(50).default(20),
});

export type ListBookmarksQuery = z.infer<typeof listBookmarksQuerySchema>;
