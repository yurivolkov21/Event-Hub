import { z } from 'zod';

export const listUsersQuerySchema = z.object({
  search: z.string().trim().optional(),
  role: z.enum(['user', 'organizer', 'admin']).optional(),
  limit: z.coerce.number().int().positive().max(50).default(20),
});

export type ListUsersQuery = z.infer<typeof listUsersQuerySchema>;
