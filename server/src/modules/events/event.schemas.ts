import { z } from 'zod';

import { eventStatuses } from './event.model';

const objectIdSchema = z
  .string()
  .regex(/^[a-f\d]{24}$/i, 'Invalid ObjectId');

const optionalUrlSchema = z
  .string()
  .trim()
  .url('Image URL is invalid')
  .optional()
  .nullable();

const baseEventSchema = z.object({
  title: z
    .string()
    .trim()
    .min(2, 'Title must contain at least 2 characters')
    .max(120, 'Title must contain at most 120 characters'),
  description: z
    .string()
    .trim()
    .min(10, 'Description must contain at least 10 characters')
    .max(3000, 'Description must contain at most 3000 characters'),
  categoryId: objectIdSchema,
  imageUrl: optionalUrlSchema,
  startAt: z.coerce.date(),
  endAt: z.coerce.date(),
  venueName: z
    .string()
    .trim()
    .min(2, 'Venue name must contain at least 2 characters')
    .max(160, 'Venue name must contain at most 160 characters'),
  address: z
    .string()
    .trim()
    .min(2, 'Address must contain at least 2 characters')
    .max(240, 'Address must contain at most 240 characters'),
  city: z.string().trim().max(120).optional().nullable(),
  country: z.string().trim().max(120).optional().nullable(),
  latitude: z.coerce.number().min(-90).max(90).optional().nullable(),
  longitude: z.coerce.number().min(-180).max(180).optional().nullable(),
  price: z.coerce.number().min(0, 'Price must be 0 or greater'),
  capacity: z.coerce.number().int().positive('Capacity must be greater than 0'),
  status: z.enum(eventStatuses).default('published'),
});

export const createEventSchema = baseEventSchema.refine(
  (event) => event.endAt > event.startAt,
  {
    path: ['endAt'],
    message: 'End date must be after start date',
  },
);

export const updateEventSchema = baseEventSchema
  .partial()
  .refine((event) => Object.keys(event).length > 0, {
    message: 'At least one field is required',
  })
  .refine(
    (event) =>
      !event.startAt ||
      !event.endAt ||
      event.endAt > event.startAt,
    {
      path: ['endAt'],
      message: 'End date must be after start date',
    },
  );

export const eventIdParamSchema = z.object({
  id: objectIdSchema,
});

export const listEventsQuerySchema = z
  .object({
    search: z.string().trim().optional(),
    categoryId: objectIdSchema.optional(),
    status: z.enum(eventStatuses).optional(),
    date: z.coerce.date().optional(),
    minPrice: z.coerce.number().min(0).optional(),
    maxPrice: z.coerce.number().min(0).optional(),
    page: z.coerce.number().int().positive().default(1),
    limit: z.coerce.number().int().positive().max(50).default(20),
    sort: z
      .enum(['startAt', '-startAt', 'createdAt', '-createdAt', 'price', '-price'])
      .default('startAt'),
  })
  .refine(
    (query) =>
      query.minPrice === undefined ||
      query.maxPrice === undefined ||
      query.maxPrice >= query.minPrice,
    {
      path: ['maxPrice'],
      message: 'Max price must be greater than or equal to min price',
    },
  );

export type CreateEventInput = z.infer<typeof createEventSchema>;
export type UpdateEventInput = z.infer<typeof updateEventSchema>;
export type ListEventsQuery = z.infer<typeof listEventsQuerySchema>;
