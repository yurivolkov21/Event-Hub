import { z } from 'zod';

export const listUsersQuerySchema = z.object({
  search: z.string().trim().optional(),
  role: z.enum(['user', 'organizer', 'admin']).optional(),
  limit: z.coerce.number().int().positive().max(50).default(20),
});

export const updateProfileSchema = z
  .object({
    fullName: z.string().trim().min(2).max(80).optional(),
    phone: z.string().trim().max(30).nullable().optional(),
    bio: z.string().trim().max(500).nullable().optional(),
    avatarUrl: z.string().trim().url().nullable().optional(),
    dateOfBirth: z.coerce.date().nullable().optional(),
    location: z.string().trim().max(120).nullable().optional(),
    gender: z.enum(['male', 'female', 'other']).nullable().optional(),
    interests: z.array(z.string().trim().min(1).max(40)).max(20).optional(),
  })
  .refine((data) => Object.keys(data).length > 0, {
    message: 'At least one field is required',
  });

export type ListUsersQuery = z.infer<typeof listUsersQuerySchema>;
export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
