import { z } from 'zod';

const objectIdSchema = z
  .string()
  .regex(/^[a-f\d]{24}$/i, 'Invalid ObjectId');

export const createBookingSchema = z.object({
  eventId: objectIdSchema,
  quantity: z.coerce.number().int().positive().max(10).default(1),
});

export const bookingIdParamSchema = z.object({
  id: objectIdSchema,
});

export const listBookingsQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(50).default(20),
  status: z.enum(['confirmed', 'cancelled']).optional(),
});

export type CreateBookingInput = z.infer<typeof createBookingSchema>;
export type ListBookingsQuery = z.infer<typeof listBookingsQuerySchema>;
