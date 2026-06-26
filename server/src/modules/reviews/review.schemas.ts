import { z } from 'zod';

export const createReviewSchema = z.object({
  rating: z.coerce.number().int().min(1).max(5),
  comment: z.string().trim().max(1000).optional().default(''),
});

export const eventIdParamSchema = z.object({
  eventId: z.string().regex(/^[a-f\d]{24}$/i, 'Invalid event id'),
});

export type CreateReviewInput = z.infer<typeof createReviewSchema>;
